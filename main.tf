terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# VPC
resource "aws_vpc" "langflow_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    AccountId   = var.aws_account_id
  }
}

# Internet Gateway
resource "aws_internet_gateway" "langflow_igw" {
  vpc_id = aws_vpc.langflow_vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    AccountId   = var.aws_account_id
  }
}

# Public Subnet
resource "aws_subnet" "langflow_public_subnet" {
  vpc_id                  = aws_vpc.langflow_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
    AccountId   = var.aws_account_id
  }
}

# Route Table
resource "aws_route_table" "langflow_public_rt" {
  vpc_id = aws_vpc.langflow_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.langflow_igw.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
    AccountId   = var.aws_account_id
  }
}

# Route Table Association
resource "aws_route_table_association" "langflow_public_rta" {
  subnet_id      = aws_subnet.langflow_public_subnet.id
  route_table_id = aws_route_table.langflow_public_rt.id
}

# Security Group
resource "aws_security_group" "langflow_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Langflow instance"
  vpc_id      = aws_vpc.langflow_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Langflow"
    from_port   = 7860
    to_port     = 7860
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Environment = var.environment
    AccountId   = var.aws_account_id
  }
}

# IAM Role for EC2
resource "aws_iam_role" "langflow_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
    AccountId   = var.aws_account_id
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "langflow_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.langflow_role.name
}

# Key Pair
resource "aws_key_pair" "langflow_key" {
  key_name   = "${var.project_name}-key"
  public_key = var.public_key
}

# EC2 Instance
resource "aws_instance" "langflow_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.langflow_key.key_name
  vpc_security_group_ids = [aws_security_group.langflow_sg.id]
  subnet_id              = aws_subnet.langflow_public_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.langflow_profile.name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    langflow_port = var.langflow_port
  }))

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-instance"
    Environment = var.environment
    AccountId   = var.aws_account_id
  }
}

# Elastic IP
resource "aws_eip" "langflow_eip" {
  instance = aws_instance.langflow_instance.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-eip"
    Environment = var.environment
    AccountId   = var.aws_account_id
  }

  depends_on = [aws_internet_gateway.langflow_igw]
}

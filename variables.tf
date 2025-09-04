variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "112113402575"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "langflow-demo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

variable "langflow_port" {
  description = "Port for Langflow application"
  type        = number
  default     = 7860
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
  validation {
    condition     = can(regex("^ssh-", var.public_key))
    error_message = "The public_key must be a valid SSH public key starting with 'ssh-'."
  }
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

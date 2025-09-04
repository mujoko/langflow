output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.langflow_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.langflow_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.langflow_instance.public_dns
}

output "langflow_url" {
  description = "URL to access Langflow application"
  value       = "http://${aws_eip.langflow_eip.public_ip}:${var.langflow_port}"
}

output "langflow_url_nginx" {
  description = "URL to access Langflow via Nginx reverse proxy"
  value       = "http://${aws_eip.langflow_eip.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/langflow-key ubuntu@${aws_eip.langflow_eip.public_ip}"
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.langflow_vpc.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.langflow_public_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.langflow_sg.id
}

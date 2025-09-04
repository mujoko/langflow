# Langflow Demo on AWS

This Terraform configuration deploys a Langflow demo instance on AWS with a complete infrastructure setup including VPC, EC2, and security configurations.

## Architecture

- **VPC**: Custom VPC with public subnet
- **EC2 Instance**: Ubuntu 22.04 LTS with Langflow installed
- **Security**: Security group allowing HTTP/HTTPS and Langflow access
- **Networking**: Internet Gateway, Route Tables, and Elastic IP
- **Reverse Proxy**: Nginx configured as reverse proxy for port 80 access

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** installed (>= 1.0)
3. **SSH Key Pair** for instance access

## Quick Start

### 1. Clone and Configure

```bash
# Navigate to the project directory
cd /Users/mujoko/work/langflow

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars
```

### 2. Update Configuration

Edit `terraform.tfvars` with your specific values:

```hcl
# Required: Add your SSH public key
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... your-actual-public-key"

# Optional: Customize other settings
aws_region = "us-west-2"
project_name = "my-langflow-demo"
instance_type = "t3.medium"
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access Langflow

After deployment completes (5-10 minutes), access Langflow using the provided URLs:

```bash
# Get the output URLs
terraform output langflow_url
terraform output langflow_url_nginx
```

## Configuration Options

### Instance Types

| Type | vCPUs | Memory | Use Case |
|------|-------|--------|----------|
| t3.small | 2 | 2 GB | Light testing |
| t3.medium | 2 | 4 GB | **Recommended** |
| t3.large | 2 | 8 GB | Heavy workloads |
| t3.xlarge | 4 | 16 GB | Production |

### Security Configuration

- **SSH Access**: Configurable CIDR blocks (default: 0.0.0.0/0)
- **Langflow Port**: 7860 (configurable)
- **HTTP/HTTPS**: Ports 80/443 open for web access
- **Encryption**: EBS volumes encrypted at rest

## Accessing the Instance

### SSH Access

```bash
# Use the SSH command from Terraform output
terraform output ssh_command

# Or manually:
ssh -i ~/.ssh/your-key ubuntu@<public-ip>
```

### Service Management

```bash
# Check Langflow service status
sudo systemctl status langflow

# View logs
sudo journalctl -u langflow -f

# Restart service
sudo systemctl restart langflow
```

## Monitoring and Troubleshooting

### Health Check

```bash
# On the instance
/home/langflow/health_check.sh

# Or via curl
curl http://localhost:7860/health
```

### Log Files

- **Installation**: `/var/log/langflow-install.log`
- **Service**: `sudo journalctl -u langflow`
- **Nginx**: `/var/log/nginx/access.log`, `/var/log/nginx/error.log`

### Common Issues

1. **Service not starting**: Check logs with `sudo journalctl -u langflow`
2. **Port access issues**: Verify security group rules
3. **Installation failures**: Check `/var/log/langflow-install.log`

## Customization

### Environment Variables

Modify `user_data.sh` to add environment variables:

```bash
Environment=LANGFLOW_CONFIG_DIR=/home/langflow/.langflow
Environment=LANGFLOW_LOG_LEVEL=INFO
```

### Additional Packages

Add to the user data script:

```bash
# Install additional Python packages
/home/langflow/langflow-env/bin/pip install package-name
```

## Cost Optimization

- Use **t3.small** for development/testing
- Enable **detailed monitoring** only if needed
- Consider **Spot instances** for non-production workloads
- Set up **auto-shutdown** for demo environments

## Security Best Practices

1. **Restrict SSH access** to your IP range
2. **Use IAM roles** instead of access keys
3. **Enable CloudTrail** for audit logging
4. **Regular security updates** via user data
5. **Consider using ALB** with SSL termination for production

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Support

For issues with:
- **Terraform**: Check AWS provider documentation
- **Langflow**: Visit [Langflow Documentation](https://docs.langflow.org/)
- **AWS**: Consult AWS documentation

## License

This configuration is provided as-is for demonstration purposes.

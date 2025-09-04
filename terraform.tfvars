# AWS Configuration
aws_region = "us-east-1"
aws_account_id = "112113402575"

# Project Configuration
project_name = "langflow-demo"
environment  = "demo"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

# EC2 Configuration
instance_type      = "t3.medium"
root_volume_size   = 20

# Langflow Configuration
langflow_port = 7860

# SSH Configuration
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEYtjq4QMfI54NfgkI8dmey3N0RNsCIGg9zrF2XvWYPouzQXrSQ5QqiTvA3IFvCoEAjrh0mc+1G89Ikr0Qi988dzpovVt0/Sff05mlkvBqwnVd9CKZsS5NcBXWR+7BfGBRrmrXiB3unQaWah1zi5uNB4CfyMOIx4qsNzG4m/TaDVBW0941h00IO6OzBMfRZskH91sIfB82Smz1kd/O2fZjej6OimWSauCtzPhN2bq4XUoagxdpKDIVhln30rtfyUGVrpLSEu9sqEZxJOfsISlHUwZvO7WK5b/BSi2eXe7nQz87Nu7kwRueUsK0ulkVmDPiE5bWLcLrG6Q7OnmuTaL+x8eOlZztHnMXrPtVQT+33wz7VkrknCzCUY5PuwGxWZtzd+WAKfXqIuy9pZqBtkWKeHt67rO/zKg+YqdScn55eqeX1zExWQdL6H2Hr5uPr3JAx4f2hzhvp3dcchgE9YGdj2RZK5rk5adyBUTg5W7llGIx+kyTSbYvUjU1miKN233UDMwstvHSUG4NI8+KZuKwXiV9aCXDrdmU4aFOktMHfckliqjwiUY8pc4pOP8Ntk76TnMvDX/O5al8JpCumj0KEEg+N/R/48sq819a2z/sD0vuJ1inN/+tmEkztZnx2e5CAEwRtBp6SG1K2BTX5SQ+eafvndtb5QdownWqlj3nSQ=="
allowed_ssh_cidr = ["0.0.0.0/0"]

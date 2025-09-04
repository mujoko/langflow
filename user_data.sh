#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y python3 python3-pip python3-venv curl wget git

# Install uv (modern Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Create langflow user
useradd -m -s /bin/bash langflow
usermod -aG sudo langflow

# Install uv for langflow user
sudo -u langflow bash << 'EOF'
cd /home/langflow
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Create virtual environment
~/.cargo/bin/uv venv langflow-env
source langflow-env/bin/activate

# Install langflow
~/.cargo/bin/uv pip install langflow
EOF

# Create systemd service file
cat > /etc/systemd/system/langflow.service << 'EOF'
[Unit]
Description=Langflow Service
After=network.target

[Service]
Type=simple
User=langflow
WorkingDirectory=/home/langflow
Environment=PATH=/home/langflow/langflow-env/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/home/langflow/langflow-env/bin/langflow run --host 0.0.0.0 --port ${langflow_port}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable langflow.service
systemctl start langflow.service

# Install nginx for reverse proxy (optional)
apt-get install -y nginx

# Configure nginx
cat > /etc/nginx/sites-available/langflow << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:${langflow_port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }
}
EOF

# Enable nginx site
ln -s /etc/nginx/sites-available/langflow /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# Create a simple health check script
cat > /home/langflow/health_check.sh << 'EOF'
#!/bin/bash
curl -f http://localhost:${langflow_port}/health || exit 1
EOF

chmod +x /home/langflow/health_check.sh
chown langflow:langflow /home/langflow/health_check.sh

# Log installation completion
echo "Langflow installation completed at $(date)" >> /var/log/langflow-install.log

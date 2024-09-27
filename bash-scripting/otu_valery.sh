#!/bin/bash

# Define variables
NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_CONF_BACKUP="/etc/nginx/nginx.conf.bak"
DEFAULT_SITE_CONF="/etc/nginx/sites-available/default"
NGINX_LOG_DIR="/var/log/nginx"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if NGINX is installed
check_nginx_installed() {
    if command_exists nginx; then
        echo "NGINX is already installed."
        return 0
    else
        return 1
    fi
}

# Function to install NGINX
install_nginx() {
    echo "Updating package lists..."
    sudo apt-get update

    echo "Installing NGINX..."
    sudo apt-get install -y nginx

    if [ $? -ne 0 ]; then
        echo "Failed to install NGINX. Exiting."
        exit 1
    else
        echo "NGINX installed successfully."
    fi
}

# Function to backup the default configuration if it exists
backup_nginx_conf() {
    if [ -f "$NGINX_CONF" ]; then
        echo "Backing up existing NGINX configuration..."
        sudo cp "$NGINX_CONF" "$NGINX_CONF_BACKUP"
        echo "Backup created at $NGINX_CONF_BACKUP."
    fi
}

# Function to configure NGINX (add custom configurations here)
configure_nginx() {
    echo "Creating a custom NGINX configuration..."

    # Example: setting up a default server block
    if [ -f "$DEFAULT_SITE_CONF" ]; then
        sudo mv "$DEFAULT_SITE_CONF" "${DEFAULT_SITE_CONF}.bak"
    fi

    cat <<EOF | sudo tee "$DEFAULT_SITE_CONF" > /dev/null
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Logging
    access_log $NGINX_LOG_DIR/access.log;
    error_log $NGINX_LOG_DIR/error.log warn;
}
EOF

    echo "Custom configuration created at $DEFAULT_SITE_CONF."
}

# Function to restart NGINX to apply changes
restart_nginx() {
    echo "Restarting NGINX service..."
    sudo systemctl restart nginx

    if [ $? -ne 0 ]; then
        echo "Failed to restart NGINX. Please check the configuration."
        exit 1
    else
        echo "NGINX restarted successfully."
    fi
}

# Function to check and create log directory
create_log_dir() {
    if [ ! -d "$NGINX_LOG_DIR" ]; then
        echo "Creating NGINX log directory at $NGINX_LOG_DIR..."
        sudo mkdir -p "$NGINX_LOG_DIR"
        sudo chown -R www-data:www-data "$NGINX_LOG_DIR"
        echo "Log directory created and permissions set."
    fi
}

# Function to enable firewall rule for NGINX
enable_firewall() {
    if command_exists ufw; then
        echo "Enabling firewall rule for NGINX..."
        sudo ufw allow 'Nginx HTTP'
    else
        echo "Firewall (ufw) is not installed. Skipping firewall configuration."
    fi
}

# Main script execution
echo "Starting NGINX installation and configuration script..."

# Step 1: Check if NGINX is already installed
if check_nginx_installed; then
    echo "Skipping installation as NGINX is already installed."
else
    install_nginx
fi

# Step 2: Backup existing NGINX configuration
backup_nginx_conf

# Step 3: Configure NGINX
configure_nginx

# Step 4: Create log directory if not exists
create_log_dir

# Step 5: Enable firewall rule for NGINX
enable_firewall

# Step 6: Restart NGINX to apply new configurations
restart_nginx

echo "NGINX installation and configuration completed successfully."


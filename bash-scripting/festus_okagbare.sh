#!/bin/bash

# Define variables
NGINX_CONF="/etc/nginx/nginx.conf"
BACKUP_DIR="/etc/nginx/backup"

# Check if NGINX is already installed
if which nginx > /dev/null 2>&1; then
    echo "NGINX is already installed."
else
    echo "Installing NGINX..."
    sudo apt update
    sudo apt install nginx -y
fi

# Ensure NGINX service is enabled and running
echo "Starting NGINX service..."
sudo service nginx start

# Check if backup directory exists, if not create it
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory..."
    sudo mkdir -p "$BACKUP_DIR"
    echo "Backup directory created on $(date +"%Y-%m-%d %H:%M")." # Add date when directory is created

else
    echo "Backup directory already exists."
fi

# Backup the existing NGINX config file
if [ -f "$NGINX_CONF" ]; then
    echo "Backing up NGINX configuration..."
    BACKUP_FILE="$BACKUP_DIR/nginx.conf.bak"
    sudo cp "$NGINX_CONF" "$BACKUP_FILE"
    echo "Backup of NGINX configuration created at $BACKUP_FILE on $(date +"%Y-%m-%d-%H:%M")."  # Add date when backup is made
else
    echo "NGINX configuration file does not exist. No backup created."
fi

# Restart NGINX service to apply any changes
sudo service nginx restart

echo "NGINX installation and configuration completed."


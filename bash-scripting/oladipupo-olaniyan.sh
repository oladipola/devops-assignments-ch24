#!/bin/bash

# Function to check the existence of NGINX
check_nginx_installed() {
    if command -v nginx > /dev/null; then
        echo "NGINX is already installed."
        return 0
    else
        echo "NGINX is not installed, proceeding with installation."
        return 1
    fi
}

# Install NGINX
install_nginx() {
    sudo apt update && sudo apt install -y nginx
    if [ $? -eq 0 ]; then
        echo "NGINX installed successfully."
    else
        echo "Error installing NGINX."
        exit 1
    fi
}

# Backup existing NGINX config
backup_nginx_config() {
    if [ -f /etc/nginx/nginx.conf ]; then
        echo "Backing up existing NGINX config."
        sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
        if [ $? -eq 0 ]; then
            echo "Backup created at /etc/nginx/nginx.conf.bak."
        else
            echo "Error creating backup."
            exit 1
        fi
    fi
}

# Function to create a sample NGINX config
configure_nginx() {
    local config_path="/etc/nginx/sites-available/default"

    echo "Configuring NGINX..."
    sudo bash -c "cat > $config_path" <<EOL
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

    if [ $? -eq 0 ]; then
        echo "NGINX configuration updated successfully."
    else
        echo "Error updating NGINX configuration."
        exit 1
    fi
}

# Restart NGINX service
restart_nginx() {
    echo "Restarting NGINX..."
    sudo systemctl restart nginx
    if [ $? -eq 0 ]; then
        echo "NGINX restarted successfully."
    else
        echo "Error restarting NGINX."
        exit 1
    fi
}

# Check if Git is installed
check_git_installed() {
    if command -v git > /dev/null; then
        echo "Git is installed."
    else
        echo "Git is not installed, installing Git..."
        sudo apt install -y git
        if [ $? -eq 0 ]; then
            echo "Git installed successfully."
        else
            echo "Error installing Git."
            exit 1
        fi
    fi
}

# Git branch creation, commit, and pull request
create_branch_and_pull_request() {
    git_repo_dir="/etc/nginx"
    
    if [ ! -d "$git_repo_dir" ]; then
        echo "Initializing Git repository in $git_repo_dir"
        cd $git_repo_dir
        sudo git init
        sudo git add .
        sudo git commit -m "Initial commit"
    else
        cd $git_repo_dir
    fi
    
    # Create a new branch
    branch_name="nginx-config-update"
    sudo git checkout -b $branch_name
    sudo git add .
    sudo git commit -m "Updated NGINX configuration"
    
    # Push branch to remote repository (ensure remote is set)
    sudo git push origin $branch_name
    
    echo "Pull request creation process complete. You may need to create the PR manually on the platform."
}

# Main Script Execution

# 1. Check if NGINX is installed
check_nginx_installed
if [ $? -eq 1 ]; then
    # 2. Install NGINX if not installed
    install_nginx
fi

# 3. Backup existing NGINX configuration
backup_nginx_config

# 4. Configure NGINX with a basic server block
configure_nginx

# 5. Restart NGINX to apply new configuration
restart_nginx

# 6. Check if Git is installed
check_git_installed

# 7. Create a Git branch and make a pull request
create_branch_and_pull_request

echo "NGINX installation and configuration completed successfully."

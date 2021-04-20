#!/bin/bash

# Last update: 2021-04-19
# This scripts sets everything needed to run an Ubuntu server to run a React frontend,
# Python Flask backend repository from Github. This includes:
#   -Environment variables
#   -Aliases
#   -Unix setup
#   -Setup of all website components and dependencies
#   -Setup website's database
#   -Firewall setup

echo "Running Install Script"

HERE=`dirname $0`
source "$HERE/formatting.sh"

# Set environment variables and aliases, using user input
"$HERE/variables.sh"
"$HERE/aliases.sh"

# Droplet Setup
"$HERE/droplet-setup.sh"

# Install gunicorn
sudo apt install gunicorn

# Install all components
"$HERE/components/repo.sh"
"$HERE/components/python.sh"
"$HERE/components/redis.sh"
"$HERE/components/postgres.sh"
"$HERE/components/nginx.sh"
"$HERE/components/npm.sh"

# Create backend assets directories
cd "$PACKAGE_ROOT/$PACKAGE_NAME/backend"
mkdir assets
mkdir assets/gallery
mkdir assets/messaging
mkdir assets/plant

# Setup database and populate with default data
cd "$PACKAGE_ROOT/$PACKAGE_NAME/backend/tools/"
python3 dbTools.py

# Enable firewall
sudo ufw enable
# Add nginx to firewall whitelist
sudo ufw allow 'Nginx Full'

# Give website SSL certificate
"$HERE/certificate.sh"

echo "Build complete! Please reboot droplet using 'sudo reboot' to ensure all changes take effect"

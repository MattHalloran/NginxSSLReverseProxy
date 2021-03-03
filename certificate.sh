#!/bin/bash

# Installs an SSL certificate using the Let's Encrypt method

# Install latest version of snapd
sudo snap install core
sudo snap refresh core

# Remove Certbot OS packages
sudo apt-get remove certbox

# Install Certbot
sudo snap install --classic Certbot

# Prepare the Certbot command
# (ensure that it can be run)
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Run certbox
sudo certbot certonly --nginx
# When prompted, enter email address
# When promted, enter domain name (ex: hellothere.com, www.hellothere.com)
# When prompted, enter webroot (frontend build directory path)

# Test automatic renewal
sudo certbot renew --dry-run
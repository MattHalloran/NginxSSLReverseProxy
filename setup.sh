#!/bin/bash

# Last update: 2021-02-28
# This scripts sets up an Ubuntu server to run a React frontend,
# Python Flask backend repository from Github
# --------- Environment Variables Setup ------------------
# 1) User-entered values stored to environment file
# --------- Unix Setup ------------------
# 1) Update packages
# --------- Git Setup ------------------
# 1) Install Git
# 2) Clone repository
# 3) Navigate into repository
# --------- Python Setup ------------------
# 1) Install pip
# 2) Install dependencies
# --------- Task Queue Setup ------------------
# 1) Create redis directory
# 2) Download redis release
# 3) Install redis release
# --------- PostgreSQL Setup ------------------
# 1) 
# --------- Backend setup -----------------
# 3) Set up git
# 4) Download backend repository
# 5) Download python dependencies
# 6) Set up Redis task queue system
# 7) Set up PostgreSQL
# 8) Set environment variables
# 9) Create assets directories
# 10) Execute database setup script
# ---------- Frontend setup ---------------
# 10) Install npm
# 11) Download frontend repository
# 12) Install npm packages
# 13) Update max listeners

echo "Running Install Script"

HERE=`dirname $0`
source "$HERE/formatting.sh"

# Unix Setup
GROUP="Unix Setup"
header
# 1) Clean up apt library
MSG="Cleaning up apt library"
checker sudo rm -rvf /var/lib/apt/lists/*
# 2) Upgrade the cache limit
echo "Upgrading cache limit"
echo "APT::Cache-Limit "100000000";" >> /etc/apt/apt.conf.d/70debconf
# 3) Update packages
MSG="Checking for updates"
checker sudo apt-get update
MSG="Running upgrade"
checker sudo apt-get -y upgrade
# 4) Install gunicorn
sudo apt install gunicorn

# Git Setup
GROUP="Github and Repository Setup"
INFO="If downloading a private repository, this will require you to enter your Github credentials"
header
# 1) Install Git
MSG="Installing git"
checker sudo apt install git
# 2) Clone repository
MSG="Clone repository"
cd
checker git clone $PACKAGE_URL

# Python Setup (Ubuntu server already has python installed)
GROUP="Python Setup"
header
# 1) Install pip
MSG="Installing pip for Python 3"
checker sudo apt install -y python3-pip
# 2) Install virtualenv
MSG="Installing virtualenv"
checker pip3 install virtualenv
# 3) Create python environment for backend
MSG="Creating python environment"
cd "$PACKAGE_ROOT/$PACKAGE_NAME/backend"
checker virtualenv site_env
# 4) Set python environment as newly created one
MSG="Setting python environment"
checker source site_env/bin/activate
# 5) Make sure environment has updated pip
MSG="Updating environment's pip"
checker python -m pip install -U pip
# 6) Install dependencies
MSG="Installing pip requirements from requirements.txt"
checker pip install -r requirements.txt
# 7) Exit virtual environment
deactivate

# Task Queue Setup
GROUP="Task Queue Setup"
INFO="This uses Redis"
header
# 1) Create redis directory
cd
MSG="Creating redis directory"
checker mkdir redis
cd redis
# 2) Download redis release
MSG="Installing Redis release 6.0.10"
checker wget https://download.redis.io/releases/redis-6.0.10.tar.gz
MSG="Extracting Redis release file"
checker tar xzf redis-6.0.10.tar.gz
MSG="Making Redis release"
cd redis-6.0.10
# 3) Install redis release
checker make
MSG="Allowing redis-server and redis-cli commands to be called from anywhere"
checker sudo make install
MSG="Download python redis dependencies"
pip3 install redis rq

# PostgreSQL Setup
GROUP="PostgreSQL Setup"
header
# Download (on Mac use "brew install postgres" instead )
# Remove existing postgres, if any
MSG="Purging existing postgresql, if any"
checker sudo apt-get --purge remove postgresql postgresql-contrib
MSG="Installing postgresql and postgresql-contrib"
checker sudo apt-get install postgresql postgresql-contrib
# Make sure postgres server is running
# **NOTE: To start postgres on Mac, use "brew services start postgresql"
MSG="Starting postgres service"
checker service postgresql start
# PostgreSQL comes with a postgres user. It is recommended to use a different user. So we will create a new one with the username and password in the config file
# **NOTE: If postgres user was not created, enter "/usr/local/opt/postgres/bin/createuser -s postgres"
# On Mac, enter "psql -h localhost -d postgres"
MSG="Creating user"
checker sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
MSG="Giving user superuser permissions"
checker sudo -u postgres psql -c "ALTER USER $DB_USER WITH SUPERUSER;"

# 9) Create backend assets directories
cd "$PACKAGE_ROOT/$PACKAGE_NAME/backend"
mkdir assets
mkdir assets/gallery
mkdir assets/messaging
mkdir assets/plant

# 10) Setup database and populate with default data
#cd
#cd "$PACKAGE_NAME/backend/tools/"
#python3 dbTools.py

# Install Nginx (once installed, edit as shown in 14:46 https://www.youtube.com/watch?v=oykl1Ih9pMg)
sudo apt install nginx
# Enable nginx so that it automatically starts if the server restarts
sudo systemctl enable nginx
# Set the nginx settings
cp "$HERE/nginxSettings.txt" /etc/nginx/sites-available/default
# Restart nginx so it can use the new settings
sudo service nginx restart

# Enable firewall
sudo ufw enable
# Add nginx to firewall whitelist
sudo ufw allow 'Nginx Full'

# Give website SSL certificate
sudo apt-add-repository -r ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python3-certbot-nginx
sudo certbot --nginx -d newlifenurseryinc.com -d www.newlifenurseryinc.com

# 11) Install npm
sudo apt install nodejs
sudo apt install npm


# 13) Install npm packages
cd "$PACKAGE_ROOT/$PACKAGE_NAME/frontend/"
npm install
# Fix vulnerabilities
npm audit fix

# Create frontend production build
npm run build
# Install package to serve React
sudo npm install -g serve
# Install package to help server stay up
sudo npm install -g pm2


# 14) Update max listeners
# npm uses a lot of listeners. Not sure exactly what they do, but the default max amount is not enough
echo fs.inotify.max_user_watches=20000 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "$(tput setaf 2)Build complete! Please reboot droplet using 'sudo reboot' to ensure all changes take effect"
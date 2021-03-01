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

# Define global variables
HERE=`dirname $0`
# (ex url: https://github.com/MattHalloran/NLN.git)
PACKAGE_URL="https://github.com/MattHalloran/NLN.git"
PACKAGE_NAME="NLN"
# Must match config.py in backend src directory
DB_USER="siteadmin"
FLASK_ROUTE="src/routes.py"

# Load functions to help with echo formatting
source "$HERE/formatting.sh"

# Environment Variables Setup
# In a Mac terminal, you can enter  'env | grep SOME_STRING' to search for environment variables
GROUP="Environment Variables Setup"
INFO="You will need to paste in several variables"
header
# Currently, there are 7 environment variables which need to be set
ENV_PATH = "/etc/environment"
# Add the following to the file. Do not delete any of the existing lines
read -p "Enter DB_PASSWORD: " DB_PASSWORD
echo $DB_PASSWORD >> $ENV_PATH
read -p "Enter NLN_SIGN_KEY: " NLN_SIGN_KEY
echo $NLN_SIGN_KEY >> $ENV_PATH
read -p "Enter TWILIO_ACCOUNT_SID: " TWILIO_ACCOUNT_SID
echo $TWILIO_ACCOUNT_SID >> $ENV_PATH
read -p "Enter TWILIO_AUTH_TOKEN: " TWILIO_AUTH_TOKEN
echo $TWILIO_AUTH_TOKEN >> $ENV_PATH
read -p "Enter AFA_EMAIL_USERNAME: " AFA_EMAIL_USERNAME
echo $AFA_EMAIL_USERNAME >> $ENV_PATH
read -p "Enter AFA_EMAIL_FROM: " AFA_EMAIL_FROM
echo $AFA_EMAIL_FROM >> $ENV_PATH
read -p "Enter AFA_EMAIL_PASSWORD: " AFA_EMAIL_PASSWORD
echo $AFA_EMAIL_PASSWORD >> $ENV_PATH
FLASK_APP=$FLASK_ROUTE

# Unix Setup
# 1) Clean up apt library
sudo rm -rvf /var/lib/apt/lists/*
# 2) Upgrade the cache limit
echo "APT::Cache-Limit "100000000";" >> /etc/apt/apt.conf.d/70debconf
# 1) Update packages
GROUP="Unix Setup"
MSG="Checking for updates"
header
checker sudo apt-get update
MSG="Running upgrade"
checker sudo apt-get -y upgrade

# Git Setup
GROUP="Github and Repository Setup"
INFO="This will require you to enter your Github credentials"
header
# 1) Install Git
MSG="Installing git"
checker sudo apt install git
# 2) Clone repository
MSG="Clone repository"
cd
checker git clone $PACKAGE_URL
# 3) Navigate into repository
MSG="Navigating into project directory"
checker cd $PACKAGE_NAME

# Python Setup (Ubuntu server already has python installed)
GROUP="Python Setup"
header
# 1) Install pip
MSG="Installing pip3"
checker sudo apt install -y python3-pip
# 2) Install dependencies
MSG="Installing pip3 requirements from requirements.txt"
cd backend
checker pip3 install -r requirements.txt

# Task Queue Setup
GROUP="Task Queue Setup"
INFO="This uses Redis"
header
# 1) Create redis directory
MSG="Navigating to / directory"
checker cd
MSG="Creating redis directory"
checker mkdir redis
MSG="Navigating to redis directory"
checker cd redis
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
MSG="Installing postgresql and postgresql-contrib"
checker sudo apt-get install postgresql postgresql-contrib
# Make sure postgres server is running
# **NOTE: To start postgres on Mac, use "brew services start postgresql"
#service postgresql start
# PostgreSQL comes with a postgres user. It is recommended to use a different user. So we will create a new one with the username and password in the config file
# **NOTE: If postgres user was not created, enter "/usr/local/opt/postgres/bin/createuser -s postgres"
# On Mac, enter "psql -h localhost -d postgres"
#sudo -u postgres "psql -c \"CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';\""
#sudo -u postgres "psql -c \"ALTER USER $DB_USER WITH SUPERUSER;\""

# 9) Create assets directories
mkdir assets
mkdir assets/gallery
mkdir assets/messaging
mkdir assets/plant

# 10) Setup database and populate with default data
cd "~/$PACKAGE_NAME/backend/tools/"
python3 dbTools.py

# 11) Install npm
sudo apt install nodejs
sudo apt install npm


# 13) Install npm packages
cd "~/$PACKAGE_NAME/frontend/"
npm install

# Create frontend production build
npm run build
sudo npm install -g serve


# 14) Update max listeners
# npm uses a lot of listeners. Not sure exactly what they do, but the default max amount is not enough
echo fs.inotify.max_user_watches=20000 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
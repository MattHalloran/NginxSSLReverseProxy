#!/bin/bash

# Last update: 2021-02-28
# This script is used to start all servers required for the website
# --------- Task Queue ------------------
# 1) 
# --------- Database ------------------
# 1) 
# --------- Python backend ------------------
# 1) 
# --------- React frontend ------------------
# 1) 

HERE=`dirname $0`
source "$HERE/consts.sh"
# Load functions to help with echo formatting
source "$HERE/formatting.sh"

# Start Task Queue
GROUP="Task Queue Server"
INFO="This uses Redis"
header
MSG="Navigating to / directory"
checker cd
MSG="Navigating to redis build directory"
checker cd redis/redis-6.0.10
MSG="Starting redis server"
checker src/redis-server

# Start PostgreSQL
# **NOTE: To start postgres on Mac, use "brew services start postgresql"
GROUP="Start PostgreSQL"
header
MSG="Starting postgresql service"
checker service postgresql start

# Start Python backend
GROUP="Start backend"
header
MSG="Activating python environment"
cd
cd "$PACKAGE_NAME/backend"
chcker source site_env/bin/activate
MSG="Starting server using gunicorn"
# nohup ensures that the process continues to run when logged out
checker nohup gunicorn --workers=2 -b :5000 src.routes:app &

# Start React frontend
GROUP="Start frontend"
header
MSG="Serving production build"
cd
cd "$PACKAGE_NAME/frontend"
checker pm2 serve build 3000 --spa

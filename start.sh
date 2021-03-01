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
chcker virtualenv site_env
MSG="Starting server using gunicorn"
checker gunicorn -b :5000 src.routes:app &

# Start React frontend
GROUP="Start frontend"
header
MSG="Serving production build"
cd
cd "$PACKAGE_NAME/frontend"
checker serve -s build -l 3000 &
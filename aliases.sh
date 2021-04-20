#!/bin/bash

# Last update: 20201-04-15
# Creates all aliases necessary to manage the site's servers
# If you wish to rewrite old aliases, you  must remove them from ~/.bashrc yourself

FILE_PATH="~/.bashrc"

# Sets an alias. If alias already exists,
# it is replaced with the new value
# Params:
#   1) The alias name
#   2) The alias value
setAlias() {
    # Remove existing matching lines
    grep -vwE "$1" $FILE_PATH > $FILE_PATH
    # Add new line
    echo "$1=\"$2\"" >> $FILE_PATH
}

# Redis server in a process that does not stop when you log out
setAlias "redis-start-stable" "nohup redis-server &"
setAlias "redis-stop-stable" "redis-cli shutdown SAVE"

# Activate Python environment
setAlias "env_activate" "source $PACKAGE_ROOT/$PACKAGE_NAME/backend/site_env/bin/activate"

# Task worker in a process that does not stop when you log out
setAlias "task-worker-start" "nohup python $PACKAGE_ROOT/$PACKAGE_NAME/backend/worker.py &"
setAlias "task-worker-stop" "pkill -f worker.py"

# Start Python Flask server for development
setAlias "flask-start-dev" "cd $PACKAGE_ROOT/$PACKAGE_NAME/backend & flask run"
# Start Python Flask server with Gunicorn, in a process that does not stop when you log out
setAlias "flask-start" "cd $PACKAGE_ROOT/$PACKAGE_NAME/backend & nohup gunicorn --workers=2 -b :5000 src.routes:app &"
setAlias "flask-stop" "pkill -f gunicorn"

# Start React frontend for development
setAlias "react-start-dev" "npm start --prefix $PACKAGE_ROOT/$PACKAGE_NAME/frontend"
# React frontend for production. Configured with pm2
setAlias "react-start" "pm2 serve $PACKAGE_ROOT/$PACKAGE_NAME/frontend/build 3000 --name frontend --spa"
setAlias "react-stop" "pm2 stop frontend"
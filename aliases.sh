#!/bin/bash

# Last update: 20201-04-15
# Creates all aliases necessary to manage the site's servers
# If you wish to rewrite old aliases, you  must remove them from ~/.bashrc yourself

FILE_PATH="~/.bashrc"

# Prevents an alias from being added multiple times
addIfNeeded() {
        grep -qxF "$1" $FILE_PATH || echo "$1" >> $FILE_PATH
}

# Redis server in a process that does not stop when you log out
addIfNeeded 'redis-start-stable="nohup redis-server &"'
addIfNeeded 'redis-stop-stable="redis-cli shutdown SAVE"'

# Activate Python environment
addIfNeeded 'env_activate="source $PACKAGE_ROOT/$PACKAGE_NAME/backend/site_env/bin/activate"'

# Start task worker in a process that does not stop when you log out
addIfNeeded 'task-worker-start="nohup python $PACKAGE_ROOT/$PACKAGE_NAME/backend/worker.py &"'

# Start Python Flask server for development
addIfNeeded 'flask-start-dev="cd $PACKAGE_ROOT/$PACKAGE_NAME/backend & flask run"'
# Start Python Flask server with Gunicorn, in a process that does not stop when you log out
addIfNeeded 'flask-start="cd $PACKAGE_ROOT/$PACKAGE_NAME/backend & nohup gunicorn --workers=2 -b :5000 src.routes:app &"'
addIfNeeded 'flask-stop="pkill -f gunicorn"'

# Start React frontend for development
addIfNeeded 'react-start-dev="npm start --prefix $PACKAGE_ROOT/$PACKAGE_NAME/frontend"'
# React frontend for production. Configured with pm2
addIfNeeded 'react-start="pm2 serve $PACKAGE_ROOT/$PACKAGE_NAME/frontend/build 3000 --name frontend --spa"'
addIfNeeded 'react-stop="pm2 stop frontend"'
#!/bin/bash

# Last update: 20201-04-15
# Creates all aliases necessary to manage the site's servers
# Flags:
#   -r Remove aliases instead of setting

HERE=`dirname $0`
source "$HERE/formatting.sh"

COMPONENT="Aliases"
REMOVE=false
FILE_PATH="~/.bashrc"

while getopts ":r" opt; do
    case ${opt} in
        r )
            REMOVE=true
        ;;
        \? ) 
            echo "Handles $COMPONENT setup"
            echo "Usage: cmd [-u]"
            exit 1
        ;;
    esac
done

declare -a aliases=("redis-start-stable" 
                    "redis-stop-stable" 
                    "env_activate"
                    "task-worker-start"
                    "task-worker-stop"
                    "flask-start-dev"
                    "flask-start"
                    "flask-stop"
                    "react-start-dev"
                    "react-start"
                    "react-stop"
                    )

# Removes all instances of an alias
# Params:
#   1) The alias name
removeAlias() {
    # Remove existing matching lines
    grep -vwE "^$1=" $FILE_PATH > $FILE_PATH
}

# Sets an alias. If alias already exists,
# it is replaced with the new value
# Params:
#   1) The alias name
#   2) The alias value
setAlias() {
    removeAlias $1
    # Add new line
    echo "$1=\"$2\"" >> $FILE_PATH
}

add() {
    group "Setting $COMPONENT"
    # Redis server in a process that does not stop when you log out
    setAlias ${aliases[0]} "nohup redis-server &"
    setAlias ${aliases[1]} "redis-cli shutdown SAVE"
    # Activate Python environment
    setAlias ${aliases[2]} "source $PACKAGE_ROOT/$PACKAGE_NAME/backend/site_env/bin/activate"
    # Task worker in a process that does not stop when you log out
    setAlias ${aliases[3]} "nohup python $PACKAGE_ROOT/$PACKAGE_NAME/backend/worker.py &"
    setAlias ${aliases[4]} "pkill -f worker.py"
    # Start Python Flask server for development
    setAlias ${aliases[5]} "cd $PACKAGE_ROOT/$PACKAGE_NAME/backend & flask run"
    # Start Python Flask server with Gunicorn, in a process that does not stop when you log out
    setAlias ${aliases[6]} "cd $PACKAGE_ROOT/$PACKAGE_NAME/backend & nohup gunicorn --workers=2 -b :5000 src.routes:app &"
    setAlias ${aliases[7]} "pkill -f gunicorn"
    # Start React frontend for development
    setAlias ${aliases[8]} "npm start --prefix $PACKAGE_ROOT/$PACKAGE_NAME/frontend"
    # React frontend for production. Configured with pm2
    setAlias ${aliases[9]} "pm2 serve $PACKAGE_ROOT/$PACKAGE_NAME/frontend/build 3000 --name frontend --spa"
    setAlias ${aliases[10]} "pm2 stop frontend"
    success "Set $COMPONENT"
}

remove() {
    group "Removing $COMPONENT"
    for i in "${aliases[@]}"
    do
        info "Removing $i"
        removeAlias "$i"
    done
    success "Removed $COMPONENT"
}

if $REMOVE; then
    add
else
    remove
fi

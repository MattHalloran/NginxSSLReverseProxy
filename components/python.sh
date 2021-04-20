#!/bin/bash

# Last update: 2021-04-19
# Installs Pip and project's Python dependencies
# Prereqs:
#   -Project has already been downloaded
# Flags:
#   -r Uninstall

HERE=`dirname $0`
source "$HERE/../formatting.sh"

COMPONENT="Python"
UNINSTALL=false

while getopts ":u" opt; do
    case ${opt} in
        r )
            UNINSTALL=true
        ;;
        \? ) 
            echo "Handles $COMPONENT installation"
            echo "Usage: cmd [-u]"
            exit 1
        ;;
    esac
done

uninstall() {
    echo "TODO"
    exit 1
}

install() {
    group "Installing $COMPONENT"
    MSG="Installing pip for Python 3"
    checker sudo apt install -y python3-pip
    MSG="Installing virtualenv"
    checker pip3 install virtualenv
    cd "$PACKAGE_ROOT/$PACKAGE_NAME/backend"
    MSG="Creating python environment"
    checker virtualenv site_env
    MSG="Updating environment's pip"
    checker python -m pip install -U pip
    MSG="Installing pip requirements from requirements.txt"
    checker pip install -r requirements.txt
    deactivate
}

if $UNINSTALL; then
    uninstall
else
    install
fi

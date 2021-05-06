#!/bin/bash

# Last update: 2021-04-19
# Installs npm and related components
# Prereqs:
#   -Repo has already been installed
# Flags:
#   -r Uninstall

HERE=`dirname $0`
source "$HERE/../formatting.sh"

COMPONENT="NPM"
UNINSTALL=false

while getopts ":r" opt; do
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
    MSG="Installing nodejs"
    checker sudo apt install nodejs
    MSG="Installing NPM"
    checker sudo apt install npm
    MSG="Globally installing knex, for migrations"
    checker npm install -g knex
    MSG="Installing NPM packages"
    cd "$PACKAGE_ROOT/$PACKAGE_NAME/frontend/"
    checker npm install
    MSG="Fix possible vulnerabilities"
    checker npm audit fix
    MSG="Create frontend production build"
    checker npm run build
    MSG="Install package to serve React"
    checker sudo npm install -g serve
    MSG="Install package to help server stay up"
    checker sudo npm install -g pm2
}

if $UNINSTALL; then
    uninstall
else
    install
fi

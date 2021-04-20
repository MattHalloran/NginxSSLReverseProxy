#!/bin/bash

# Last update: 2021-04-19
# Installs Nginx
# Flags:
#   -r Uninstall

HERE=`dirname $0`
source "$HERE/../formatting.sh"

COMPONENT="Nginx"
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
    # Install Nginx (once installed, edit as shown in 14:46 https://www.youtube.com/watch?v=oykl1Ih9pMg)
    sudo apt install nginx
    MSG="Turn on auto-start if the server restarts"
    checker sudo systemctl enable nginx
    MSG="Update $COMPONENT settings"
    checker cp "$HERE/nginxSettings.txt" /etc/nginx/sites-available/default
    MSG="Update $COMPONENT so it can use the new settings"
    checker sudo service nginx restart
}

if $UNINSTALL; then
    uninstall
else
    install
fi

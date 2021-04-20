#!/bin/bash

# Last update: 2021-04-19
# Installs git and website's repository
# Prereqs:
#   -Project has already been downloaded
# Flags:
#   -r Uninstall

HERE=`dirname $0`
source "$HERE/../formatting.sh"

COMPONENT="Github and repository"
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
    info "If downloading a private repository, this will require you to enter your Github credentials"
    MSG="Installing git"
    checker sudo apt install git
    MSG="Cloning repository. If already cloned, this will be skipped"
    cd $PACKAGE_ROOT
    checker git clone $PACKAGE_URL
}

if $UNINSTALL; then
    uninstall
else
    install
fi

#!/bin/bash

# Last update: 2021-04-19
# Installs Redis
# Prereqs:
#   -Python and pip are already installed
# Flags:
#   -r Uninstall

HERE=`dirname $0`
source "$HERE/../formatting.sh"

COMPONENT="Redis"
VERSION="https://download.redis.io/releases/redis-6.0.10.tar.gz"
DIRECTORY="redis-6.0.10"
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
    group "Uninstalling $COMPONENT"
    cd $PACKAGE_ROOT
    if [ -d "$DIRECTORY" ]; then
        cd $DIRECTORY
        MSG="Running sudo make uninstall"
        checker sudo make uninstall
        cd ..
        MSG="Removing directory $DIRECTORY"
        checker rm -r $DIRECTORY
    else
        error "Directory not found - $DIRECTORY"
    fi
}

install() {
    group "Installing $COMPONENT"
    cd $PACKAGE_ROOT
    MSG="Installing Redis release 6.0.10"
    checker wget $VERSION
    MSG="Extracting Redis release file"
    checker tar xzf "$DIRECTORY.gz"
    cd $DIRECTORY
    MSG="Making Redis release"
    checker make
    MSG="Allowing redis-server and redis-cli commands to be called from anywhere"
    checker sudo make install
    MSG="Download python redis dependencies"
    checker pip3 install redis rq
}

if $UNINSTALL; then
    uninstall
else
    install
fi

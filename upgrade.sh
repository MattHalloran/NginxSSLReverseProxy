#!/bin/bash

# Downloads the newest version of the website.
# Moves the old version to a different directory.
# Moves assets to newest version

HERE=`dirname $0`
source "$HERE/formatting.sh"

# Stop current website processes
./$HERE/stop.sh

# Move the current version to a different directory
cd $PACKAGE_ROOT
OLD_DIRECTORY=$PACKAGE_NAME-`date +%s`
mv $PACKAGE_NAME $OLD_DIRECTORY

# Download the latest code
git clone $PACKAGE_URL

# Move old assets
mv $OLD_DIRECTORY/backend/assets $PACKAGE_NAME/backend

# Restart the website
./$HERE/start.sh
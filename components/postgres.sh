#!/bin/bash

# Last update: 2021-04-19
# Installs git and website's repository
# Prereqs:
#   -Project has already been downloaded
# Flags:
#   -r Uninstall

HERE=`dirname $0`
source "$HERE/../formatting.sh"

COMPONENT="Postgres"
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
    # Download (on Mac use "brew install postgres" instead )
    # Remove existing postgres, if any
    MSG="Purging existing postgresql, if any"
    checker sudo apt-get --purge remove postgresql postgresql-contrib
    MSG="Installing postgresql and postgresql-contrib"
    checker sudo apt-get install postgresql postgresql-contrib
    # Make sure postgres server is running
    # **NOTE: To start postgres on Mac, use "brew services start postgresql"
    MSG="Starting postgres service"
    checker service postgresql start
    # PostgreSQL comes with a postgres user. It is recommended to use a different user. So we will create a new one with the username and password in the config file
    # **NOTE: If postgres user was not created, enter "/usr/local/opt/postgres/bin/createuser -s postgres"
    # On Mac, enter "psql -h localhost -d postgres"
    MSG="Creating user"
    checker sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
    MSG="Giving user superuser permissions"
    checker sudo -u postgres psql -c "ALTER USER $DB_USER WITH SUPERUSER;"
}

if $UNINSTALL; then
    uninstall
else
    install
fi

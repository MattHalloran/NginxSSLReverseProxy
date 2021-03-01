#!/bin/bash

# These functions help to prettify echos

# Prints group with information
header () {
    echo "$(tput setaf 7)$GROUP"
    if [[ $(ls $INFO | wc -c) -ne 0 ]]; then
        echo "$(tput setaf 2)$INFO"
        INFO=""
    fi
}

# Wrapper function for printing "PASS" or "FAIL"
checker () {
    echo "$(tput setaf 7)$GROUP - $MSG"
    if "$@"; then
        echo "$(tput setaf 1)Pass - $MSG"
    else
        echo "$(tput setaf 2)Fail - $MSG"
    fi
}

echo "formatting.sh imported"
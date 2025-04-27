#!/bin/bash

CONFIG_FILE="$HOME/.runpconfig"
BASE_DIR=""

# Checks if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found. Creating a new one..."

    echo "Please provide the base directory to look for files:"
    read BASE_DIR

    if [ -z "$BASE_DIR" ]; then
        BASE_DIR=$(pwd)
        echo "Using the current directory ($BASE_DIR) as the base."
    fi

    echo "base_dir=$BASE_DIR" > "$CONFIG_FILE"
    echo "Configuration file created at $CONFIG_FILE"
else
    BASE_DIR=$(grep "^base_dir=" "$CONFIG_FILE" | cut -d'=' -f2)
fi

# Processes the --use option to change the base directory
if [ "$1" == "--use" ]; then
    if [ -n "$2" ]; then
        BASE_DIR="$2"
    else
        BASE_DIR=$(pwd)
    fi
    echo "Using directory ($BASE_DIR) as the base."
    echo "base_dir=$BASE_DIR" > "$CONFIG_FILE"  # Updates the configuration file
    shift 2  # Remove --use and its parameter from the arguments
fi

# Calling the runp-bin binary
runp-bin "$BASE_DIR" "$@"

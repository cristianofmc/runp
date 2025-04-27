#!/bin/bash

CONFIG_FILE="$HOME/.runpconfig"
BASE_DIR=""

# Checks if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found. Creating a new one..."
    
    # Asks the user which directory to use as the base
    echo "Please provide the base directory to look for files:"
    read BASE_DIR
    
    # If the user doesn't provide a directory, use the current directory
    if [ -z "$BASE_DIR" ]; then
        BASE_DIR=$(pwd)
        echo "Using the current directory ($BASE_DIR) as the base."
    fi

    # Creates the configuration file
    echo "base_dir=$BASE_DIR" > "$CONFIG_FILE"
    echo "Configuration file created at $CONFIG_FILE"
else
    # If the file already exists, loads the base directory
    BASE_DIR=$(grep "^base_dir=" "$CONFIG_FILE" | cut -d'=' -f2)
fi

# Processes the --use option to change the base directory
if [ "$1" == "--use" ]; then
    BASE_DIR=$(pwd)
    echo "Using the current directory ($BASE_DIR) as the base."
    echo "base_dir=$BASE_DIR" > "$CONFIG_FILE"  # Updates the configuration file
fi

# Calling the runp-bin binary
runp-bin "$BASE_DIR" "$2"

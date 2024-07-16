#!/bin/bash

set -euo pipefail

# SFTP server details
SFTP_HOST="example.com"
SFTP_USER="user"
SFTP_PASS="test"
SFTP_PORT="22"

# Remote directory
REMOTE_DIR="/hey/hello/weewoo"

# Get the file/folder path from the argument passed by Dolphin
ITEM_TO_COPY="$1"

# Extract just the name from the full path
ITEM_NAME=$(basename "$ITEM_TO_COPY")

# Function to send notifications
send_notification() {
    notify-send -u normal "SFTP Transfer" "$1"
}

# Function to handle errors
handle_error() {
    send_notification "Error: $1"
    exit 1
}

# Check if the item exists
if [ ! -e "$ITEM_TO_COPY" ]; then
    handle_error "Item does not exist: $ITEM_TO_COPY"
fi

# Prepare SFTP commands
SFTP_COMMANDS="cd $REMOTE_DIR\n"

if [ -d "$ITEM_TO_COPY" ]; then
    # It's a directory, use recursive put
    SFTP_COMMANDS+="put -r \"$ITEM_TO_COPY\" \"$ITEM_NAME\"\n"
else
    # It's a file
    SFTP_COMMANDS+="put \"$ITEM_TO_COPY\" \"$ITEM_NAME\"\n"
fi

SFTP_COMMANDS+="bye\n"

# Execute SFTP command
if ! echo -e "$SFTP_COMMANDS" | sshpass -p "$SFTP_PASS" sftp -P $SFTP_PORT $SFTP_USER@$SFTP_HOST; then
    handle_error "SFTP transfer failed for $ITEM_NAME"
fi

# If we've made it here, the transfer was successful
send_notification "Successfully copied $ITEM_NAME to remote server"

#!/bin/sh
PROCESS_NAME="puma"

echo "Checking for $PROCESS_NAME process..."

# Find the PID of the Puma process
PUMA_PID=$(ps ax | grep "$PROCESS_NAME" | grep "tcp://" | awk '{print $1}')

if [ -n "$PUMA_PID" ]; then
    echo "Found $PROCESS_NAME process with PID: $PUMA_PID. Terminating it..."
    kill "$PUMA_PID"
    echo "$PROCESS_NAME process terminated."
else
    echo "No $PROCESS_NAME process found running."
fi

#!/bin/sh

USER_HOME=$(eval echo ~)
export PATH="${USER_HOME}/.rubies/ruby-3.2.2/bin:${PATH}"

# Setup the environment
if [ -z "${SERVER_HOST}" ]; then
    parent_directory="$(cd "$(dirname "$0")" && pwd)/.."

    if [ -f "${parent_directory}/.env" ]; then
        set -a
        . "${parent_directory}/.env"
        if [ $? -ne 0 ]; then
            echo "*** Cannot load environment file ${parent_directory}/.env ***" >&2
            exit 2
        fi
        set +a
    else
        echo "*** Cannot find environment file ${parent_directory}/.env ***" >&2
        exit 1
    fi
fi

PROCESS_NAME="puma"

# Ensure RAILS_DIRECTORY is set
if [ -z "${RAILS_DIRECTORY}" ]; then
    export RAILS_DIRECTORY="$(cd "$(dirname "$0")" && pwd)/.."
fi

echo "Checking for $PROCESS_NAME process running already..."

# Find the PID of the Puma process
PUMA_PID=$(ps ax | grep "$PROCESS_NAME" | grep -v grep | awk '{print $1}')

if [ -n "$PUMA_PID" ]; then
    echo "Found $PROCESS_NAME process with PID: $PUMA_PID. Terminating it..."
    kill "$PUMA_PID"
    echo "$PROCESS_NAME process terminated."

    # Ensure the process is fully terminated
    DELAY_SECONDS=3
    echo "Waiting for $DELAY_SECONDS seconds before starting the server..."
    sleep "$DELAY_SECONDS"
else
    echo "No $PROCESS_NAME process found running."
fi

# Ensure SERVER_PORT is set
if [ -z "$SERVER_PORT" ]; then
    echo "SERVER_PORT is not set. Using default port 3000."
    SERVER_PORT=3000
fi

cd "${RAILS_DIRECTORY}" || { echo "Can't change to ${RAILS_DIRECTORY} directory." >&2; exit 3; }

# Start the Puma server
echo "Starting the server..."

if [ "$NOHUP" = "true" ]; then
    nohup "${RAILS_DIRECTORY}/bin/bundle" exec rails s -b 0.0.0.0 -p "$SERVER_PORT" > log/server.log 2>&1 &
    sleep 3
else
    echo "Running: ${RAILS_DIRECTORY}/bin/bundle exec rails s -b 0.0.0.0 -p $SERVER_PORT"
    "${RAILS_DIRECTORY}/bin/bundle" exec rails s -b 0.0.0.0 -p "$SERVER_PORT"

    if [ $? -ne 0 ]; then
        echo "Can't run ${RAILS_DIRECTORY}/bin/bundle exec rails s -b 0.0.0.0 -p $SERVER_PORT." >&2
        exit 4
    fi
fi

exit 0

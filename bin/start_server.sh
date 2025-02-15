#!/bin/sh

# Setup the environment

if [ -z "${SERVER_HOST}" ]; then
    if [ -f "./.env" ]; then
      set -a
        . ./.env

        if [ $? -ne 0 ]; then
          echo "*** Cannot load environment file ./.env ***"
          exit 2
        fi
      set +a
    else
      echo "*** Cannot find environment file ./.env ***"
      exit 1
    fi
fi

PROCESS_NAME="puma"

if [ -z "${RAILS_DIRECTORY}" ]; then
    RAILS_DIRECTORY="."
fi

echo "Checking for $PROCESS_NAME process running already..."

# Find the PID of the Puma process
PUMA_PID=$(ps ax | grep "$PROCESS_NAME" | grep -v grep | awk '{print $1}')

if [ -n "$PUMA_PID" ]; then
    echo "Found $PROCESS_NAME process with PID: $PUMA_PID. Terminating it..."
    kill "$PUMA_PID"
    echo "$PROCESS_NAME process terminated."

    # Add a delay to ensure the process is fully terminated
    DELAY_SECONDS=3
    echo "Waiting for $DELAY_SECONDS seconds before starting the server..."
    sleep "$DELAY_SECONDS"
else
    echo "No $PROCESS_NAME process found running on port $PORT."
fi

cd "${RAILS_DIRECTORY}"

if [ $? -ne 0 ]; then
    echo "Can't change to ${RAILS_DIRECTORY} directory."
    exit 3
fi

# Start the Puma server
echo "Starting the server..."

if [ "${NOHUP}" == "true" ]; then
  nohup "${RAILS_DIRECTORY}/bin/bundle" exec rails s > log/server.log 2>&1 &
  sleep 3
else
  "${RAILS_DIRECTORY}/bin/bundle" exec rails s -b 0.0.0.0 -p "${SERVER_PORT}"

  if [ $? -ne 0 ]; then
    echo "Can't run ${RAILS_DIRECTORY}/bin/bundle exec rails s -b 0.0.0.0 -p ${SERVER_PORT}."
    exit 3
  fi
fi

#!/bin/sh
PROCESS_NAME="puma"
HOST=ENV.fetch('SERVER_HOST', 'localhost')
PORT=ENV.fetch('INTERNAL_PORT', '3000')

echo "Checking for $PROCESS_NAME process on port $PORT..."

# Find the PID of the Puma process
PUMA_PID=$(ps ax | grep "$PROCESS_NAME" | grep "tcp://$HOST:$PORT" | awk '{print $1}')

if [ -n "$PUMA_PID" ]; then
    echo "Found $PROCESS_NAME process with PID: $PUMA_PID. Terminating it..."
    kill "$PUMA_PID"
    echo "$PROCESS_NAME process terminated."
else
    echo "No $PROCESS_NAME process found running on port $PORT."
fi

# Add a delay to ensure the process is fully terminated
DELAY_SECONDS=3
echo "Waiting for $DELAY_SECONDS seconds before starting the server..."
sleep "$DELAY_SECONDS"

rm log/development.log
touch log/development.log
# Start the Puma server
echo "Starting the server..."
if [ "${NOHUP}" == "false" ]; then
  bin/bundle exec rails s
else
  nohup bin/bundle exec rails s > log/server.log 2>&1 &
  sleep 3
fi

# open -a "Google Chrome" --args --remote-debugging-port=9222 "http://#{ENV.fetch('SERVER_HOST', '3000')}:#{ENV.fetch('INTERNAL_PORT', '3000')}"

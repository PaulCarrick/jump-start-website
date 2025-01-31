#!/bin/sh
# rails-startup.sh

cd /rails || { echo "Failed to change directory to /rails"; exit 1; }

# Setup the environment
status="Okay"

if [ -f "./.env" ]; then
  set -a
    . ./.env

    if [ $? -ne 0 ]; then
      echo "*** Cannot load environment file ./.env ***"

      status=""
    fi
  set +a
else
  echo "*** Cannot find environment file ./.env ***"

  status=""
fi

# Create Gems Directory
if [ -n "${status}" ] && [ ! -d "/rails/gems" ]; then
    echo "Creating gems directory under /rails..."
    mkdir -p /rails/gems || { echo "Failed to create gems directory." >&2; status=""; }
    echo "Gems directory created."
fi

# Install Bundler
if [ -n "${status}" ]; then
    echo "Installing bundler..."
    gem install bundler -v '~> 2.5' || { echo "Failed to install bundler." >&2; status=""; }
    echo "Bundler installed."
fi

# Install Gems
if [ -n "${status}" ]; then
    echo "Installing gems with Bundler..."
    bundle install || { echo "Failed to install gems." >&2; status=""; }
    echo "Gems installed."
fi

# Run Database Migrations
if [ -n "${status}" ]; then
    echo "Running database migrations..."
    bundle exec rails db:migrate || { echo "Failed to migrate the database." >&2; status=""; }
    echo "Database migrations completed."
fi

# Precompile Assets (for Production)
if [ -n "${status}" ] && [ "${RAILS_ENV}" = "production" ]; then
    echo "Precompiling assets for production..."
    bundle exec rails assets:precompile || { echo "Failed to precompile assets." >&2; status=""; }
    echo "Assets precompiled."
fi

# Start the Rails Server
if [ -n "${status}" ]; then
    echo "Starting Rails server on port ${INTERNAL_PORT}..."
    bundle exec rails server -b 0.0.0.0 -p "${INTERNAL_PORT}" || { echo "Failed to start the Rails server." >&2; status=""; }
    echo "Rails server started."
fi

# Final Status
if [ -n "${status}" ]; then
    echo "Rails application is ready."
else
    echo "Rails setup encountered errors." >&2
    exit 1
fi

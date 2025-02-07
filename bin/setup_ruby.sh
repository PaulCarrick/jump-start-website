#!/bin/bash

# Script to setup ruby

set -e  # Exit on error

db_name=$1
db_username=$2
db_password=$3

if [ -z "${db_name}" ]; then
  if [ -n "$DB_NAME" ]; then
    db_name="$DB_NAME"
  else
    echo "Please enter a database name." >&2
    exit 1
  fi
fi

if [ -z "${db_username}" ]; then
  if [ -n "$DB_USERNAME" ]; then
    db_username="$DB_USERNAME"
  else
    echo "Please enter a database username." >&2
    exit 1
  fi
fi

if [ -z "${db_password}" ]; then
  if [ -n "$DB_PASSWORD" ]; then
    db_password="$DB_PASSWORD"
  else
    echo "Please enter a database password." >&2
    exit 1
  fi
fi

# Run Ruby Setup Script
ruby bin/setup.rb "$db_name" "$db_username" "$db_password"

# Install Bundler
echo "Installing Bundler..."

if ! gem install bundler -v '~> 2.5' --no-document; then
  echo "Failed to install Bundler." >&2
  exit 1
fi

echo "Bundler installed."

# Install Gems
echo "Installing gems with Bundler..."

if ! bundle install; then
  echo "Failed to install gems." >&2
  exit 1
fi

echo "Gems installed."

# Set Rails environment to production if not set
export RAILS_ENV=${RAILS_ENV:-production}

# Run Database Migrations
echo "Running database migrations..."

if ! bundle exec rails db:migrate; then
  echo "Failed to migrate the database." >&2
  exit 1
fi

echo "Database migrations completed."

# Precompile Assets (for Production)
if [ "${RAILS_ENV}" = "production" ]; then
  echo "Precompiling assets for production..."

  if ! bundle exec rails assets:precompile; then
    echo "Failed to precompile assets." >&2
    exit 1
  fi

  echo "Assets precompiled."
fi

echo "Jump Start Server configured successfully."
exit 0

#!/bin/sh

# compose.sh

set -e

app=$1
shift;
direction=$1
shift;

if [ -z "${app}" ]; then command="rails" ; fi
if [ -z "${direction}" ]; then direction="up" ; fi

env_file="startup/${app}/.env"

if [ -f "${env_file}" ]; then
  set -a
    . ${env_file}

    if [ $? -ne 0 ]; then
      echo "Cannot load environment file ${env_file}"
      exit 2
    fi
  set +a
else
  echo "Cannot find environment file ${env_file}"
  exit 1
fi

echo "Composing Docker ${app} container..."
docker compose -p "${PROJECT_NAME}" -f docker-compose-${app}.yml --env-file ${env_file} ${direction} | tee log/${app}-compose.log
result=$?

if [ $result -eq 0 ]; then
    echo "Docker ${app} container composed successfully."
else
    echo "Docker ${app} container compose failed."
    exit $result
fi

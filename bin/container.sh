#!/bin/sh

# container.sh

set -e

app=$1
shift;
command=$1
shift;

if [ -z "${app}" ]; then command="rails" ; fi
if [ -z "${command}" ]; then command="start" ; fi

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

container_name=${PROJECT_NAME}_${app}

echo "Controling ${app} container. Command: ${command}..."
docker ${command} ${container_name}
result=$?

if [ $result -eq 0 ]; then
    echo "Docker ${app} container. Command: ${command} succeeded." # this won't normally be hit as run never returns if successful unless ^c hit
else
    echo "Docker ${app} container. Command: ${command} failed."
    exit $result
fi

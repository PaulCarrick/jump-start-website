#!/bin/sh

# build.sh

set -e

app=$1

if [ -z "${app}" ]; then command="rails" ; fi

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

# Read each line in the .env file
while IFS='=' read -r key value || [ -n "$key" ]; do
    # Ignore empty lines and comments
    if [ -n "$key" ] && [ "${key#\#}" = "$key" ]; then
        # Trim whitespace and export in the format --build-arg KEY=VALUE
        build_args="$build_args --build-arg $key=$value"
    fi
done < "${env_file}"

image_name=${PROJECT_NAME}_${app}
log_name=log/${app}-build.log

echo "Build Docker ${app} image..."

options=$2

if [ "${options}" = "VERBOSE" ]; then
    echo "docker build -f Dockerfile-${app} --progress=plain -t ${image_name} ${build_args} . 2>&1 | tee ${log_name}"
fi

docker build -f Dockerfile-${app} --progress=plain -t ${image_name} ${build_args} . 2>&1 | tee ${log_name}
result=$?

if [ $result -eq 0 ]; then
    echo "Docker ${app} image composed successfully."
else
    echo "Docker ${app} image compose failed."
    exit $result
fi

#!/bin/sh

if [ -f "startup/.env" ]; then
  set -a
    . startup/.env

    if [ $? -ne 0 ]; then
      echo "Cannot load environment file startup/.env"
      exit 2
    fi
  set +a
else
  echo "Cannot find environment file startup/.env"
  exit 1
fi

INCLUDE_STORAGE_FLAG=false

for arg in "$@"; do
  if [ "$arg" = "INCLUDE_STORAGE" ]; then
    INCLUDE_STORAGE_FLAG=true
    break
  fi
done

DATE_STRING=`date +"%m-%d-%Y"`
USER=${DB_USERNAME}
HOST=${DB_HOST}
PORT=${DB_PORT}
DATABASE=${DB_DATABASE}
DESTINATION_NAME=${DB_DATABASE}
LOCAL_DUMP_NAME="${DESTINATION_NAME}_database_${DATE_STRING}.dump"
LOCAL_STORAGE_NAME="${DESTINATION_NAME}_images_${DATE_STRING}.tar.gz"

pg_dump -h "${HOST}" -p "${PORT}" -U "${USER}" -d "${DATABASE}" -F c -f "${HOME}/${LOCAL_DUMP_NAME}"

if [ $? -ne 0 ]; then
  echo "Error: Failed to backup ${HOME}/${LOCAL_DUMP_NAME}"
  exit 1
fi

if [ "$INCLUDE_STORAGE_FLAG" = "true" ]; then
    tar --dereference -czvf "${HOME}/${LOCAL_STORAGE_NAME}" storage/

    if [ $? -ne 0 ]; then
      echo "Error: Failed to create ${REMOTE_STORAGE_NAME} in ${HOME}"
      exit 1
    fi
fi

echo "${DATABASE} backed up successfully."
exit 0;

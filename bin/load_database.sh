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
NO_COPY_FLAG=false

for arg in "$@"; do
  if [ "$arg" = "INCLUDE_STORAGE" ]; then
    INCLUDE_STORAGE_FLAG=true
  fi

  if [ "$arg" = "NO_COPY" ]; then
    NO_COPY_FLAG=true
  fi
done

export PGPASSWORD="${DB_PASSWORD}"

REMOTE_SERVER="${USERNAME}@${SITE_HOST}"
DESTINATION_NAME=${DB_DATABASE}
DATE_STRING=`date +"%m-%d-%Y"`
DUMP_NAME="${DESTINATION_NAME}_database_${DATE_STRING}.dump"
REMOTE_DUMP_NAME="${REMOTE_SERVER}:${DUMP_NAME}"
LOCAL_BACKUP_DUMP="${DESTINATION_NAME}_local_database_${DATE_STRING}.dump"
REMOTE_STORAGE_NAME="${REMOTE_SERVER}:${DESTINATION_NAME}_images_${DATE_STRING}.tar.gz"
LOCAL_STORAGE_NAME="${DESTINATION_NAME}_images_${DATE_STRING}.tar.gz"
LOCAL_STORAGE_DUMP="${DESTINATION_NAME}_local_images_${DATE_STRING}.tar.gz"

if [ "$NO_COPY_FLAG" = "false" ]; then
    scp "${REMOTE_DUMP_NAME}" "${HOME}"

    if [ $? -ne 0 ]; then
      echo "Error: Failed to copy ${REMOTE_DUMP_NAME} to ${HOME}"
      exit 1
    fi

    if [ "$INCLUDE_STORAGE_FLAG" = "true" ]; then
        scp "${REMOTE_STORAGE_NAME}" "${HOME}"

        if [ $? -ne 0 ]; then
          echo "Error: Failed to copy ${REMOTE_STORAGE_NAME} to ${HOME}"
          exit 1
        fi
    fi
fi

pg_dump -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" -d "${DB_DATABASE}" -F c -f "${HOME}/${LOCAL_BACKUP_DUMP}"

if [ $? -ne 0 ]; then
  echo "Error: Failed to backup ${HOME}/${LOCAL_BACKUP_DUMP}"
  exit 1
fi

psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '${DB_DATABASE}' AND pid <> pg_backend_pid();"

dropdb -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" "${DB_DATABASE}"

if [ $? -ne 0 ]; then
  echo "Error: Failed to drop ${DB_DATABASE}"
  exit 1
fi

createdb -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" "${DB_DATABASE}"

if [ $? -ne 0 ]; then
  echo "Error: Failed to drop ${DB_DATABASE}"
  exit 1
fi

pg_restore --no-owner -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" -d "${DB_DATABASE}" "${HOME}/${DUMP_NAME}"

if [ $? -ne 0 ]; then
  echo "Error: Failed to restore ${HOME}/${DUMP_NAME}"
  exit 1
fi

if [ "$INCLUDE_STORAGE_FLAG" = "true" ]; then
    tar -czvf "${HOME}/${LOCAL_STORAGE_DUMP}" storage/

    if [ $? -ne 0 ]; then
      echo "Error: Failed to create ${LOCAL_STORAGE_DUMP} in ${HOME}"
      exit 1
    fi

    rm -rf storage/*

    if [ $? -ne 0 ]; then
      echo "Error: Failed to delete storage"
      exit 1
    fi

    tar -xzvf "${HOME}/${LOCAL_STORAGE_NAME}"

    if [ $? -ne 0 ]; then
      echo "Error: Failed to restore ${HOME}/${LOCAL_STORAGE_NAME}"
      exit 1
    fi
fi

echo "${DB_DATABASE} restored successfully."
exit 0

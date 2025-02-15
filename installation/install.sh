#!/bin/sh

# configure.sh

set -e

if command -v pip >/dev/null 2>&1; then
    pip_installed=true
else
    pip_installed=""
fi

if [ -z "${pip_installed}" ]; then
  sudo apt update
  sudo apt install -y pip
fi

pip_list=`pip list`
validators=`echo ${pip_list} | grep "validators"`
psychopg=`echo ${pip_list} | grep "psycopg2-binary"`
dotenv=`echo ${pip_list} | grep "python-dotenv"`

if [ -z "${validators}" ]; then
  sudo pip install validators --break-system-packages > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "Can't install python validators package." >&2
    exit 1
  fi
fi

if [ -z "${psychopg}" ]; then
  sudo pip install psycopg2-binary --break-system-packages > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "Can't install python psycopg2 package." >&2
    exit 2
  fi
fi

if [ -z "${dotenv}" ]; then
  sudo pip install python-dotenv --break-system-packages > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "Can't install python dotenv package." >&2
    exit 3
  fi
fi

cd "$(dirname $0)" && sudo python3 install.py

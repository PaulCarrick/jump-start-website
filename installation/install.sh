#!/bin/sh

# configure.sh

set -e

sudo apt update
sudo apt install -y pip

pip_list=`pip list`
validators=`echo ${pip_list} | grep "validators"`
psychopg=`echo ${pip_list} | grep "psycopg2-binary"`
dotenv=`echo ${pip_list} | grep "python-dotenv"`

if [ -z "${validators}" ]; then
  sudo pip install validators --break-system-packages
fi

if [ -z "${psychopg}" ]; then
  sudo pip install psycopg2-binary --break-system-packages
fi

if [ -z "${dotenv}" ]; then
  sudo pip install python-dotenv --break-system-packages
fi

cd "$(dirname $0)" && sudo python3 install.py

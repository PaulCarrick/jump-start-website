#!/bin/sh

# configure.sh

set -e

sudo apt update
sudo apt install -y pip

if pip list | grep -q "^validators "; then
  echo "validators package already installed."
else
  sudo pip install validators --break-system-packages
fi

if pip list | grep -q "^psycopg2-binary "; then
  echo "psycopg2 package already installed."
else
  sudo pip install psycopg2-binary --break-system-packages
fi

if pip list | grep -q "^python-dotenv "; then
  echo "dotenv package already installed."
else
  sudo pip install python-dotenv --break-system-packages
fi

cd "$(dirname $0)" && sudo python3 install.py

#!/bin/sh

# configure.sh

set -e

sudo apt update
sudo apt install -y pip
sudo pip install validations --break-system-packages
sudo pip install psycopg2-binary --break-system-packages
sudo pip install python-dotenv --break-system-packages

cd "$(dirname $0)" && sudo python3 configure.py

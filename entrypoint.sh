#!/bin/sh

# Check if logindata is provided
if [ -z "$goguser" ]; then
  echo "Error: logindata is not provided"
  exit 1
fi

# Run the login command
python gogrepoc.py login $goguser $gogpassword
python gogrepoc.py update $updatecommands
python gogrepoc.py download $downloadcommands /gogrepocdock/downloads
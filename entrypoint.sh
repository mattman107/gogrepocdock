#!/bin/sh

# Check if logindata is provided
if [ -z "$goguser" ] || [ -z "$gogpassword" ]; then
  echo "Error: logindata is not provided"
  exit 1
fi

# Set the default value for repeat interval to 24 hours if not set
if [ -z "$repeat" ]; then
  echo "Repeat interval is not set. Defaulting to 1 week."
  repeat="1w"
fi

# Convert repeat interval to seconds if necessary
case $repeat in
  *d) repeat=$((${repeat%d} * 86400)) ;;   # Converts days to seconds
  *w) repeat=$((${repeat%w} * 604800)) ;;  # Converts weeks to seconds
  *) echo "Invalid repeat interval. Please use a valid time format (e.g., 3d, 1w)." && exit 1 ;;
esac

# Function to execute the commands
execute_commands() {
  # Run the login command
  python gogrepoc.py login "$goguser" "$gogpassword"
  python gogrepoc.py update "$updatecommands"
  python gogrepoc.py download "$downloadcommands" /gogrepocdock/downloads
}

# Initial command execution
execute_commands

# Loop the command execution every $repeat seconds
while true; do
  # Start time for the loop iteration
  start_time=$(date +%s)

  # Execute the commands
  execute_commands

  # End time for the loop iteration
  end_time=$(date +%s)

  # Calculate the elapsed time
  elapsed_time=$((end_time - start_time))

  # Calculate the sleep time to ensure $repeat interval
  sleep_time=$((repeat - elapsed_time))

  # Ensure that sleep_time is non-negative
  if [ $sleep_time -gt 0 ]; then
    sleep $sleep_time
  fi
done

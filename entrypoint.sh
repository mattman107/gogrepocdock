#!/bin/sh

# Pull the latest version of the gogrepoc.py file if we need
wget -N https://raw.githubusercontent.com/Kalanyr/gogrepoc/refs/heads/master/gogrepoc.py

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
  python gogrepoc.py login $goguser $gogpassword
  python gogrepoc.py update $updatecommands
  python gogrepoc.py download $downloadcommands /gogrepocdock/downloads
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
    # Determine the echo interval based on the total sleep time
    if [ $sleep_time -gt 604800 ]; then
      echo_interval=86400  # Echo every day if sleep_time > 1 week
    elif [ $sleep_time -gt 43200 ]; then
      echo_interval=3600   # Echo every hour if sleep_time > 1 day and <= 1 week
    elif [ $sleep_time -gt 3600 ]; then
      echo_interval=1200   # Echo every hour if sleep_time > 1 day and <= 1 week    
    else
      echo_interval=60      # Echo every minute if sleep_time <= 1 hour
    fi

    # Echo the remaining time at the defined interval
    while [ $sleep_time -gt 0 ]; do
      # Sleep for the defined interval or the remaining time if less than the interval
      sleep_time=$((sleep_time - echo_interval))
      [ $sleep_time -lt 0 ] && sleep_time=0

      days=$((sleep_time / 86400))
      hours=$((sleep_time % 86400 / 3600))
      minutes=$((sleep_time % 3600 / 60))
      seconds=$((sleep_time % 60))

      if [ $days -gt 0 ]; then
        echo "$days days until next sync."
      elif [ $hours -gt 0 ]; then
        echo "$hours hours until next sync."
      else
        echo "$minutes minutes until next sync."
      fi

      # Sleep for the echo interval or remaining time if less
      [ $sleep_time -gt 0 ] && sleep $((sleep_time > echo_interval ? echo_interval : sleep_time))
    done
  fi
done


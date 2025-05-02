#!/bin/bash

THRESHOLD=80

# email or log file for alerts (optional)
ALERT_LOG="/path/to/alert_log.txt"

# get current disk usage percentage for root filesystem
USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

# check if usage exceeds threshold
if [ "$USAGE" -gt "$THRESHOLD" ]; then
  MESSAGE="Warning: Disk usage is at ${USAGE}% on $(hostname)"
  echo "$MESSAGE" | tee -a "$ALERT_LOG"
else
  echo "Disk usage is under control: ${USAGE}% used."
fi

echo "Disk usage check completed."  
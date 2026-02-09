#!/bin/bash

THRESHOLD=80
ALERT_LOG="/var/log/disk_alerts.log"

# to check disk usage on root (/)
USAGE=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
  MESSAGE="WARNING: Root disk usage is at ${USAGE}% on $(hostname)"
  echo "$MESSAGE"
  echo "$MESSAGE" >> "$ALERT_LOG"
else
  echo "Disk usage is OK: ${USAGE}% used."
fi
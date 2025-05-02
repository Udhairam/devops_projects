#!/bin/bash

# *(month)  *(day)  *(hour)  *(minute)  *(seconds)    

job="0 2 * * * /path/to/script.sh"                                  
script="/path/to/script.sh"


if [ ! -x "$script" ]; then
  echo "Error: $script does not exist or is not executable."
  exit 1
fi


if crontab -l 2>/dev/null | grep -F "$job" >/dev/null; then
  echo "Cron job already exists. Skipping..."
else
  echo "Adding cron job..."
  (crontab -l 2>/dev/null; echo "$job") | crontab -
  echo "Cron job added successfully!"
fi

#!/bin/bash

log_directory = "/logs_path"

days_threshold = 60

logs_deleted = "/deleted_logs.txt"

if [ ! -d "$log_directory" ]; then
    echo "Log directory $log_directory does not exist" >&2
    exit 1
fi

find "$log_directory" -type f -name "*.log" -mtime +$days_threshold -print -delete >> "$logs_deleted" 2>&1

echo "log files that are older than $days_threshold have been deleted"


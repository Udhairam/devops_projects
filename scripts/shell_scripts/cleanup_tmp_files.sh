#!/bin/bash

temp_dir="/tmp"
retention_days=7

echo "Cleaning up files older than $retention_days days in $temp_dir..."

#delete old files
find "$temp_dir" -type f -mtime +$retention_days -exec rm -f {} \;

#delete empty directories
find "$temp_dir" -type d -empty -delete

echo "Cleanup completed."
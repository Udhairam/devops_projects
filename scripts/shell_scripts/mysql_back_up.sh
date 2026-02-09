#!/bin/bash

db_name="mydatabase"
backup_dir="/backup/mysql"
retention_days=7
timestamp=$(date +'%Y-%m-%d_%H-%M')
backup_file="$backup_dir/${db_name}_$timestamp.sql"

# Create backup directory if it doesn't exist
mkdir -p "$backup_dir"

echo "Starting backup for database: $db_name"

# Run the backup
mysqldump "$db_name" > "$backup_file"

if [ $? -eq 0 ]; then
    echo "Backup saved to $backup_file"
else
    echo "Backup failed"
    exit 1
fi

# Remove old backups
find "$backup_dir" -type f -name "${db_name}_*.sql" -mtime +$retention_days -exec rm -f {} \;

echo "Old backups cleaned up (older than $retention_days days)"
echo "Backup process completed"


#create a cron job for this script and the script will automatically back up the database and delete backups which are older than 7 days
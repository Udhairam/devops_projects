#!/bin/bash

source = "/source_path"
destination = "/dest_path"

DATE = $(date +%Y-%m-%d)

echo "backing up files from $source to $destination/$DATE"

mkdir -p "$destination/$DATE"

cp -r "$source" /* "$destination/$DATE"

echo "Backed up files successfully"


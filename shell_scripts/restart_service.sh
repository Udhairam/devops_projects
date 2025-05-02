#!/bin/bash

service = "alpine"

if ! is-active --quiet "$service"; then
    echo "$service server is not Running, now restarting..."
    sudo systemctl restart $service
else
    echo "$service server is up and running"
fi


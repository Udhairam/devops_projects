#!/bin/bash


echo "Top 5 processes by CPU usage:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
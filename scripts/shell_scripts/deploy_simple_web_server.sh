#!/bin/bash

echo "installing nginx server"

sudo apt update
sudo apt install -y nginx

systemctl start nginx 
systemctl enable nginx

echo "Nginx server is up and running"
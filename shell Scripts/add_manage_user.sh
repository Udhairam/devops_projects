#!/bin/bash


USERNAME="newuser"
PASSWORD="password123"
GROUP="sudo"

echo "Creating user $USERNAME..."
sudo useradd -m -s /bin/bash "$USERNAME"

echo "$USERNAME:$PASSWORD" | sudo chpasswd
echo "Adding $USERNAME to $GROUP group..."

sudo usermod -aG "$GROUP" "$USERNAME"
echo "User $USERNAME created and added to $GROUP!"
#!/bin/bash


# Update the system's package index
echo "Updating system package index..."
sudo yum check-update

# Upgrade all available packages
echo "Upgrading system packages..."
sudo yum update -y

# clean up cached data
echo "Cleaning up cached packages..."
sudo yum clean all


echo "System update and upgrade completed successfully!"
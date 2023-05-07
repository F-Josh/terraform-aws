#!/bin/bash

# Update the package list and upgrade existing packages
sudo apt-get update

# Install the Apache HTTP Server
sudo apt-get install -y apache2 

# Start the Apache service
sudo systemctl start apache2

# Enable the Apache service to start on boot
sudo systemctl enable apache2


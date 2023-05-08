#!/bin/bash

# Update the package list and upgrade existing packages
sudo apt-get update

# Install the Apache HTTP Server
sudo apt-get install -y apache2 git

#Download the source code from git
git clone https://github.com/gabrielecirulli/2048.git

#put the spurce code into the webserver root directory
sudo cp -R 2048/* /var/www/html/  ## this is the weberver root for apache

# Start the Apache service
sudo systemctl start apache2

# Enable the Apache service to start on boot
sudo systemctl enable apache2


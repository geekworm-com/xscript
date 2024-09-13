#!/bin/bash

echo "Start installing fan service..."

sudo cp -f ./x-c1-fan.sh                /usr/local/bin/
sudo chmod +x /usr/local/bin/x-c1-fan.sh
sudo cp -f ./x-c1-fan.service           /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable x-c1-fan
sudo systemctl start x-c1-fan

echo "Fan service installed"

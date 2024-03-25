#!/bin/bash

echo "Start installing the power management service..."

# sudo cp -f ./x-c1-pwr.sh              /usr/local/bin/
sudo cp -f ./xPWR.sh                    /usr/local/bin/
sudo cp -f x-c1-pwr.service             /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable x-c1-pwr
sudo systemctl start x-c1-pwr

echo "Power management service installed"
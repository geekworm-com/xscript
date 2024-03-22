#!/bin/bash

# Uninstall x-c1-fan.service:
sudo systemctl stop x-c1-fan
sudo systemctl disable x-c1-fan

file_path="/lib/systemd/system/x-c1-fan.service"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/x-c1-fan.sh"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

sudo sed -i '/dtoverlay=pwm-2chan/d' /boot/firmware/config.txt

# Uninstall x-c1-pwr.service
sudo systemctl stop x-c1-pwr
sudo systemctl disable x-c1-pwr
file_path="/lib/systemd/system/x-c1-pwr.service"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/x-c1-pwr.sh"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/xgpio_pwr"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

# Remove the xoff allias on .bashrc file
sudo sed -i '/xoff/d' ~/.bashrc
source ~/.bashrc

file_path="/usr/local/bin/x-c1-softsd.sh"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/xgpio_soft"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

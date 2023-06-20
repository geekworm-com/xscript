#!/bin/bash

sudo sed -i '/pwr.sh/d'      /etc/rc.local
sudo sed -i '/fan-rpi.py/d'  /etc/rc.local
sudo sed -i '/pigpio/d'      /etc/rc.local
sudo sed -i '/softsd.sh/d'  ~/.bashrc

#sudo rm -f  /etc/rc.local
sudo rm -f  /usr/local/bin/softsd.sh
sudo rm -f  /etc/pwr.sh
sudo rm -rf ~/xscript
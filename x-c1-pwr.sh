#!/bin/bash

SHUTDOWN=4
BOOT=17
REBOOTPULSEMINIMUM=200
REBOOTPULSEMAXIMUM=600

# Read the /sys/kernel/debug/gpio file to get the actual GPIO pin
SHUTDOWN=$(cat /sys/kernel/debug/gpio | grep "GPIO$SHUTDOWN" | awk -F'gpio-' '{print $2}' | awk -F' ' '{print $1}')
BOOT=$(cat /sys/kernel/debug/gpio | grep "GPIO$BOOT" | awk -F'gpio-' '{print $2}' | awk -F' ' '{print $1}')

echo "$SHUTDOWN" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio$SHUTDOWN/direction

echo "$BOOT" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$BOOT/direction
echo "1" > /sys/class/gpio/gpio$BOOT/value

echo "Your device are shutting down..."

while [ 1 ]; do
  shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
  if [ $shutdownSignal = 0 ]; then
    /bin/sleep 0.2
  else
    pulseStart=$(date +%s%N | cut -b1-13)
    while [ $shutdownSignal = 1 ]; do
      /bin/sleep 0.02
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMAXIMUM ]; then
        echo "Your device are shutting down", SHUTDOWN, ", halting Rpi ..."
        sudo poweroff
        exit
      fi
      shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
    done
    if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMINIMUM ]; then
      echo "Your device are rebooting", SHUTDOWN, ", recycling Rpi ..."
      sudo reboot
      exit
    fi
  fi
done

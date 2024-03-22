#!/bin/bash

BUTTON=27

# Read the /sys/kernel/debug/gpio file to get the actual GPIO pin
BUTTON=$(cat /sys/kernel/debug/gpio | grep "GPIO$BUTTON" | awk -F'gpio-' '{print $2}' | awk -F' ' '{print $1}')

echo "$BUTTON" > /sys/class/gpio/export;
echo "out" > /sys/class/gpio/gpio$BUTTON/direction
echo "1" > /sys/class/gpio/gpio$BUTTON/value

SLEEP=${1:-4}

re='^[0-9\.]+$'
if ! [[ $SLEEP =~ $re ]] ; then
   echo "error: sleep time not a number" >&2; exit 1
fi

echo "Your device will shutting down in 4 seconds..."
/bin/sleep $SLEEP

echo "0" > /sys/class/gpio/gpio$BUTTON/value

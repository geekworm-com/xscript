#!/bin/bash

#  Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

# In October 2025, the Raspberry Pi OS was updated from Bookworm to Trixie. The libgpiod library in Trixie has been upgraded to version 2.2.1. 
# The syntax of the gpioset command has changed, so harry@geekworm.com updated this script.
# Refer to https://libgpiod.readthedocs.io/en/latest/gpio_tools.html#examples

# Check if enough command line arguments were provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <gpio_chip> <button_pin>" >&2
    exit 1
fi

GPIOCHIP=$1
BUTTON=$2

SLEEP=4

# Checks if the passed parameter is an integer

re='^[0-9\.]+$'
if ! [[ $GPIOCHIP =~ $re ]] ; then
   echo "error: gpio_chip is not a number" >&2; exit 1
fi

if ! [[ $BUTTON =~ $re ]] ; then
   echo "error: button_pin is not a number" >&2; exit 1
fi

echo "Your device will be shutting down in $SLEEP seconds..."

# gpioset -c $GPIOCHIP -p 3s -t0 $BUTTON=1
gpioset -c $GPIOCHIP -t0 $BUTTON=1

sleep $SLEEP

# Restore GPIO
# This step is necessary, otherwise you will have to press the onboard button twice to turn on the device, and the same applies to the AUTO ON function.
gpioset -c $GPIOCHIP -t0 $BUTTON=0
#gpioset -c $GPIOCHIP -p 20ms -t0 $BUTTON=0
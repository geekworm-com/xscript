#!/bin/bash

# Use gpiod instead of the obsolete GPIO interface.

# In October 2025, the Raspberry Pi OS was updated from Bookworm to Trixie. The libgpiod library in Trixie has been upgraded to version 2.2.1. 
# The newer gpioset syntax and GPIO hold/release behavior require script changes.
# The previous adaptation used -p 2s, which specifies a minimum hold time but
# does not make gpioset exit. A subsequent GPIO reset command is therefore blocked.
# Adding -t0 makes it exit after the hold time, but releasing the line does not
# guarantee that it goes LOW.
# On X728 V2.5, a GPIO26 HIGH pulse longer than 2 seconds causes AUTO ON to fail.
# Use -t 2s,0 to drive the line LOW after 2 seconds before releasing it and exiting.
# The output state after release is not guaranteed by libgpiod.
# Updated by harry@geekworm.com.
# Refer to https://libgpiod.readthedocs.io/en/master/gpio_tools.html#examples

# Check if enough command line arguments were provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <gpio_chip> <button_pin>" >&2
    exit 1
fi

GPIOCHIP=$1
BUTTON=$2

# Checks if the passed parameter is an integer

re='^[0-9]+$'
if ! [[ $GPIOCHIP =~ $re ]] ; then
   echo "error: gpio_chip is not a number" >&2; exit 1
fi

if ! [[ $BUTTON =~ $re ]] ; then
   echo "error: button_pin is not a number" >&2; exit 1
fi

echo "Requesting safe shutdown..."

# Drive the pin high for 2 seconds, then drive it low and exit.
gpioset -c "$GPIOCHIP" -t 2s,0 "$BUTTON=1"

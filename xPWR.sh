#!/bin/bash

# In October 2025, the Raspberry Pi OS was updated from Bookworm to Trixie. The libgpiod library in Trixie has been upgraded to version 2.2.1. 
# The syntax of the gpioset command has changed, so harry@geekworm.com updated this script.
# Refer to https://libgpiod.readthedocs.io/en/latest/gpio_tools.html#examples

# Global debugging switch (0=off, 1=on)
DEBUG=0

#  Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also
# Log debug info, only when DEBUG=1 above
function logdebug {
    if [ "$DEBUG" -eq 1 ]; then
        echo "$@" >&2
    fi
}

# Log errors
function logerr {
    echo "$@" >&2
}

main() {
  local GPIOCHIP=$1
  local SHUTDOWN=$2
  local BOOT=$3

  # Make sure enough parameters are passed in
  if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <pwm_chip> <shutdown_pin> <boot_pin>"
    exit 1
  fi

  # Checks if the passed parameter is an integer
  re='^[0-9\.]+$'
  if ! [[ $GPIOCHIP =~ $re ]] ; then
    logerr "error: pwm_chip is not a number"
    exit 1
  fi

  if ! [[ $SHUTDOWN =~ $re ]] ; then
    logerr "error: shutdown_pin is not a number"
    exit 1
  fi

  if ! [[ $BOOT =~ $re ]] ; then
    logerr "error: button_pin is not a number"
    exit 1
  fi

  local REBOOTPULSEMINIMUM=200
  local REBOOTPULSEMAXIMUM=600
  local pulseStart
  local shutdownSignal
  local output

  # Initialize the BOOT pin to 1
  # 必须加上-t0参数，否则堵塞在这里了。
  gpioset -c $GPIOCHIP -t0 $BOOT=1

  while [ 1 ]; do
    output=$(gpioget -c $GPIOCHIP $SHUTDOWN)
    # "5"=inactive, get the string after =
    shutdownSignal=$(echo "$output" | awk -F '=' '{print $NF}' | tr -d '"')
    #logdebug $output
    logdebug $shutdownSignal
    if [ "$shutdownSignal" = "inactive" ]; then
      sleep 0.2
    else
      pulseStart=$(date +%s%N | cut -b1-13)

      while [ "$shutdownSignal" = "active" ]; do
        sleep 0.02
        if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMAXIMUM ]; then
          echo "Your device is shutting down on pin $SHUTDOWN, halting Rpi ..."
          sudo poweroff
          exit
        fi
        # shutdownSignal=$(gpioget $GPIOCHIP $SHUTDOWN)
        output=$(gpioget -c $GPIOCHIP $SHUTDOWN)
        shutdownSignal=$(echo "$output" | awk -F '=' '{print $NF}' | tr -d '"')
        #logdebug $output
        logdebug $shutdownSignal
      done
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMINIMUM ]; then
        echo "Your device is rebooting on pin $SHUTDOWN, recycling Rpi ..."
        sudo reboot
        exit
      fi
    fi
  done

}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

#!/bin/bash

#  Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

# 检查是否提供了足够的命令行参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <gpio_chip> <button_pin>" >&2
    exit 1
fi

PWMCHIP=$1
BUTTON=$2

SLEEP=2

# 检查传入的参数是否为整数

re='^[0-9\.]+$'
if ! [[ $PWMCHIP =~ $re ]] ; then
   echo "error: gpio_chip is not a number" >&2; exit 1
fi

if ! [[ $BUTTON =~ $re ]] ; then
   echo "error: button_pin is not a number" >&2; exit 1
fi

echo "Your device will be shutting down in $SLEEP seconds..."

gpioset $PWMCHIP $BUTTON=1

sleep $SLEEP

# Restore GPIO
# This step is necessary, otherwise you will have to press the onboard button twice to turn on the device, and the same applies to the AUTO ON function.
gpioset $PWMCHIP $BUTTON=0

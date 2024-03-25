#!/bin/bash

#  Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

# 检查是否提供了足够的命令行参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pwm_chip> <button_pin>" >&2
    exit 1
fi

PWMCHIP=$1
BUTTON=$2

SLEEP=4

# 检查传入的参数是否为整数

re='^[0-9\.]+$'
if ! [[ $PWMCHIP =~ $re ]] ; then
   echo "error: pwm_chip is not a number" >&2; exit 1
fi

if ! [[ $BUTTON =~ $re ]] ; then
   echo "error: button_pin is not a number" >&2; exit 1
fi

echo "Your device will be shutting down in $SLEEP seconds..."

gpioset --mode=time -s $SLEEP $PWMCHIP $BUTTON=1

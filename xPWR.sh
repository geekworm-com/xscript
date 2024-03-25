#!/bin/bash  

#  Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

# 确保有足够的参数被传入  
if [ "$#" -ne 3 ]; then  
  echo "Usage: $0 <pwm_chip> <shutdown_pin> <boot_pin>"  
  exit 1  
fi  

PWMCHIP=$1    
SHUTDOWN=$2  
BOOT=$3

# 检查传入的参数是否为整数
re='^[0-9\.]+$'
if ! [[ $PWMCHIP =~ $re ]] ; then
   echo "error: pwm_chip is not a number" >&2; exit 1
fi

if ! [[ $SHUTDOWN =~ $re ]] ; then
   echo "error: shutdown_pin is not a number" >&2; exit 1
fi

if ! [[ $BOOT =~ $re ]] ; then
   echo "error: button_pin is not a number" >&2; exit 1
fi

REBOOTPULSEMINIMUM=200  
REBOOTPULSEMAXIMUM=600  
  
# 初始化BOOT引脚为1  
gpioset $PWMCHIP $BOOT=1  
  
while [ 1 ]; do  
  shutdownSignal=$(gpioget $PWMCHIP $SHUTDOWN)  
  if [ $shutdownSignal -eq 0 ]; then  
    sleep 0.2  
  else  
    pulseStart=$(date +%s%N | cut -b1-13)  
    while [ $shutdownSignal -eq 1 ]; do  
      sleep 0.02  
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMAXIMUM ]; then  
        echo "Your device is shutting down on pin $SHUTDOWN, halting Rpi ..."  
        sudo poweroff  
        exit  
      fi  
      shutdownSignal=$(gpioget $PWMCHIP $SHUTDOWN)  
    done  
    if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMINIMUM ]; then  
      echo "Your device is rebooting on pin $SHUTDOWN, recycling Rpi ..."  
      sudo reboot  
      exit  
    fi  
  fi  
done

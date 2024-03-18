#!/bin/bash

SHUTDOWN=4
BOOT=17
REBOOTPULSEMINIMUM=200
REBOOTPULSEMAXIMUM=600

# linux 内核从6.1开始对GPIO的访问方式发生了变化，Ubuntu 23就是这个问题造成的
# Run the command to get the GPIO map table: cat /sys/kernel/debug/gpio
# 获取内核版本的前两部分，例如 4.19  
kernel_version=$(uname -r | awk -F. '{print $1"."$2}') 
  
# 将要比较的版本号 6.1 拆分为数组  
basee_version=("6" "1")  
  
# 将 kernel_version 拆分为数组  
kernel_version_array=($(echo $kernel_version | tr '.' ' '))  
  
# 检查数组长度是否足够  
if [ ${#kernel_version_array[@]} -ge 2 ]; then  
    # 比较主版本号和次版本号  
    if [ ${kernel_version_array[0]} -gt ${basee_version[0]} ]; then  
        SHUTDOWN=516
        BOOT=529  
    elif [ ${kernel_version_array[0]} -eq ${basee_version[0]} ] && [ ${kernel_version_array[1]} -gt ${basee_version[1]} ]; then  
        SHUTDOWN=516
        BOOT=529
    else  
        SHUTDOWN=4
        BOOT=17
    fi  
else  
    echo "Can't get the kernel version" 
    exit 1  
fi 

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

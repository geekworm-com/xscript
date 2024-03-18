#!/bin/bash

BUTTON=27


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
        BUTTON=539  
    elif [ ${kernel_version_array[0]} -eq ${basee_version[0]} ] && [ ${kernel_version_array[1]} -gt ${basee_version[1]} ]; then          
        BUTTON=539  
    else          
        BUTTON=27
    fi  
else  
    echo "Can't get the kernel version" 
    exit 1  
fi  


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

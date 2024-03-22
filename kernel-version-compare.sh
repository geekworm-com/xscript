#!/bin/bash

#This is a sample shell script, DON'T USE IT
SHUTDOWN=4
BOOT=17

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
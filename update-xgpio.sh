#!/bin/bash

# 由于ubuntu自从23.04版本的内核升级到6.2, 该内核不支持sysfs的方式来读写GPIO,所以我们用了官方推荐的libgpiod库来开发了对应的程序
# xgpio_pwr 负责电源管理，等效于x-c1-pwr.sh， xgpio_soft 负责软件关机，等效于x-c1-soft.sh；
# 要注意的这两个程序支持参数的传入，具体可参考源代码；
# 可以参考 https://github.com/geekworm-com/xgpio 来了解xgpio_pwr和xgpio_soft
# 我们需要在ubuntu环境中编译一下这个程序，也可以直接使用我们编译好的程序；

# 指定要操作的目录名  
dir_name="bin" 
  
# 检查目录是否存在 & 备份旧的bin目录
if [ -d "$dir_name" ]; then  
    # 目录存在，准备重命名  
    counter=1  
    new_dir_name="${dir_name}.${counter}"  
  
    # 检查是否存在同名的目录，如果存在则递增计数器  
    while [ -e "$new_dir_name" ]; do  
        counter=$((counter + 1))  
        new_dir_name="${dir_name}.${counter}"  
    done  
  
    # 重命名目录  
    mv "$dir_name" "$new_dir_name"  
    echo "The old catalogue has been renamed $new_dir_name" 
fi

# 创建目录结构
mkdir -p bin/ubuntu bin/bookworm    

# 下载可执行文件

wget -O bin/ubuntu/xgpio_pwr    https://github.com/geekworm-com/xgpio/raw/main/bin/ubuntu/xgpio_pwr
wget -O bin/ubuntu/xgpio_soft   https://github.com/geekworm-com/xgpio/raw/main/bin/ubuntu/xgpio_soft

wget -O bin/bookworm/xgpio_pwr  https://github.com/geekworm-com/xgpio/raw/main/bin/bookworm/xgpio_pwr
wget -O bin/bookworm/xgpio_soft https://github.com/geekworm-com/xgpio/raw/main/bin/bookworm/xgpio_soft

# 给目录bin/下的所有文件set execute access
find bin/ -type f -exec chmod +x {} \;

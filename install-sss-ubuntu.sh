#!/bin/bash

# 由于ubuntu自从23.04版本的内核升级到6.2, 该内核不支持sysfs的方式来读写GPIO,所以我们用了官方推荐的libgpiod库来开发了对应的程序
# xgpio_pwr 负责电源管理，等效于x-c1-pwr.sh， xgpio_soft 负责软件关机，等效于x-c1-soft.sh；
# 要注意的这两个程序支持参数的传入，具体可参考源代码；
# 可以参考 https://github.com/geekworm-com/xgpio 来了解xgpio_pwr和xgpio_soft
# 我们需要在ubuntu环境中编译一下这个程序，也可以直接使用我们编译好的程序；

# Install soft shutdown script (sss)
echo "Start installing the soft shutdown script (sss)..."

chmod +x bin/ubuntu/xgpio_pwr           bin/ubuntu/xgpio_soft
sudo cp -f bin/ubuntu/xgpio_soft        /usr/local/bin/

echo "Create a alias 'xoff' command to execute the software shutdown"
echo "alias xoff='sudo /usr/local/bin/xgpio_soft gpiochip0 27'" >>   ~/.bashrc
source ~/.bashrc

echo "Soft shutdown script (sss) installed"

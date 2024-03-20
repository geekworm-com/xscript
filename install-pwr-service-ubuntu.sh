#!/bin/bash

# 由于ubuntu自从23.04版本的内核升级到6.2, 该内核不支持sysfs的方式来读写GPIO,所以我们用了官方推荐的libgpiod库来开发了对应的程序
# xgpio_pwr 负责电源管理，等效于x-c1-pwr.sh， xgpio_soft 负责软件关机，等效于x-c1-soft.sh；
# 要注意的这两个程序支持参数的传入，具体可参考源代码；
# 可以参考 https://github.com/geekworm-com/xgpio 来了解xgpio_pwr和xgpio_soft
# 我们需要在ubuntu环境中编译一下这个程序，也可以直接使用我们编译好的程序；

echo "Start installing the power management service..."

chmod +x bin/ubuntu/xgpio_pwr
chmod +x bin/ubuntu/xgpio_soft
sudo cp -f bin/ubuntu/xgpio_pwr                /usr/local/bin/
sudo cp -f x-c1-pwr-ubuntu.service      /lib/systemd/system/x-c1-pwr.service
sudo systemctl daemon-reload
sudo systemctl enable x-c1-pwr
sudo systemctl start x-c1-pwr

echo "Power management service installed"
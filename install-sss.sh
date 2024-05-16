#!/bin/bash

# Install soft shutdown script (sss)
echo "Start installing the soft shutdown script (sss)..."

sudo cp -f ./xSoft.sh                /usr/local/bin/

# echo "Create a alias 'xoff' command to execute the software shutdown"
# echo "alias xoff='sudo /usr/local/bin/xSoft.sh 0 27'" >>   ~/.bashrc
source ~/.bashrc

echo "Soft shutdown script (sss) installed"
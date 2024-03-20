#!/bin/bash

# Install soft shutdown script (sss)
echo "Start installing the soft shutdown script (sss)..."

sudo cp -f ./x-c1-softsd.sh                /usr/local/bin/

echo "Create a alias 'xoff' command to execute the software shutdown"
echo "alias xoff='sudo /usr/local/bin/x-c1-softsd.sh'" >>   ~/.bashrc
source ~/.bashrc

echo "Soft shutdown script (sss) installed"
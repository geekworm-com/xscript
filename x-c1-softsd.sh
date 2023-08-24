#!/bin/bash

BUTTON=27

SLEEP=${1:-4}

re='^[0-9\.]+$'
if ! [[ $SLEEP =~ $re ]] ; then
   echo "error: sleep time not a number" >&2; exit 1
fi

echo "Your device will shutting down in 4 seconds..."

gpioset --mode=time -s $SLEEP 0 $BUTTON=1
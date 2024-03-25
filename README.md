# XScript
This is script installation tutorial for `NASPi`, `NASPi Gemini 2.5`, `NASPi CM4-M2` and `NASPi CM4-2.5`.
***
The original pwm fan control script is from [pimlie/geekworm-x-c1](https://github.com/pimlie/geekworm-x-c1), **pimlie** implements the pwm fan shell script, which does not depend on third-party python libraries at all. Thanks to **pimlie**.

User Guide: https://wiki.geekworm.com/XScript

Email：support@geekworm.com

# x708-script

User Guide: https://wiki.geekworm.com/X708-script

Email: support@geekworm.com!


# Update
Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

NASPi series does not support Raspberry Pi 5 hardwared due to different hardware interface.

## Software shutdown service:

PWM_CHIP=0

BUTTON_BIN=27
> /usr/local/bin/xSoft.sh 0 27

## Power management service

PWM_CHIP=0

SHUTDOWN=4

BOOT=17
>/usr/local/bin/xPWR.sh 0 4 17


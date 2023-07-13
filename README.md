# script-test
This is script installation tutorial for `NASPi`, `NASPi Gemini 2.5`, `NASPi CM4-M2` and `NASPi CM4-2.5`.
***
The original code is from [pimlie/geekworm-x-c1](https://github.com/pimlie/geekworm-x-c1), **pimlie** implements the pwm fan shell script, which does not depend on third-party python libraries at all. Thanks to **pimlie**.

## OS that has been tested
* Raspbian
* DietPi
* Manjaro
* Ubuntu
* myNode
* Umbrel
* Volumio

## Preconfigured `config.txt`
To install pwm fan, first add `dtoverlay=pwm-2chan` to `/boot/config.txt` under `[all]`  or the end of file and `reboot`:
<pre>
sudo nano /boot/config.txt
</pre>
**Or**    (it's `/boot/firmware/config.txt` if you are using `ubuntu`)
<pre>
sudo nano /boot/firmware/config.txt
</pre>
Save & exit.
<pre>
sudo reboot
</pre>

## Clone the script
<pre>
git clone https://github.com/geekworm-com/script-test

cd script-test
chmod +x *.sh
</pre>

## Create the `x-c1-fan` service
<pre>
sudo cp -f ./x-c1-fan.sh                /usr/local/bin/
sudo cp -f ./x-c1-fan.service           /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable x-c1-fan
sudo systemctl start x-c1-fan
</pre>
Then the pwm fan starts running

> PS: If your device does not support pwm fans or you are not using pwm, you can skip this step
>
## Create the `x-c1-pwr` service
<pre>
sudo cp -f ./x-c1-pwr.sh                /usr/local/bin/
sudo cp -f x-c1-pwr.service             /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable x-c1-pwr
sudo systemctl start x-c1-pwr
</pre>

## Prepair software shutdown
<pre>
sudo cp -f ./x-c1-softsd.sh             /usr/local/bin/
</pre>
Create a alias `xoff` command to execute the software shutdown
<pre>
echo "alias xoff='sudo /usr/local/bin/x-c1-softsd.sh'" >>   ~/.bashrc
source ~/.bashrc
</pre>
Then you can run `xoff` to execute software safe shutdown.

## Test safe shutdown
Software safe shutdown command:
<pre>
xoff
</pre>

Hardware safe shutdown operation:
* press on-board button switch 1-2 seconds to reboot
* press button switch 3 seconds to safe shutdown,
* press 7-8 seconds to force shutdown.
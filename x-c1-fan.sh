#!/usr/bin/env bash

# The pwm methods are a bash implementation of https://github.com/Pioreactor/rpi_hardware_pwm

PWM_CHANNEL=0
PWM_HERTZ=2000
PWM_CHIP_PATH=/sys/class/pwm/pwmchip0
AUTO_CLEANUP=1 # If 1 then pwm channel is unexported on script exit, if 0 then its only stopped
SLEEP_INTERVAL=5
SHOW_DEBUG=0

# Log debug info, only when SHOW_DEBUG=1 above
function logdebug {
    if [ "$SHOW_DEBUG" -eq 1 ]; then
        echo "$@" >&2
    fi
}

# Log errors
function logerr {
    echo "$@" >&2
}

# Helper util to do float comparisons without bc
function num_compare {
    awk "BEGIN {exit !($*)}"
}

# Get a path to the pwm chip
function pwm_get_chip_path {
    local SUB_PATH="$1"

    if [ -n "$SUB_PATH" ]; then
        echo "$PWM_CHIP_PATH/$SUB_PATH"
    else
        echo "$PWM_CHIP_PATH"
    fi
}

# Get a path to the pwm channel
function pwm_get_channel_path {
    local CHANNEL="$1"
    local SUB_PATH="$2"

    local PWM_PATH="$PWM_CHIP_PATH/pwm$CHANNEL"

    if [ -n "$SUB_PATH" ]; then
        echo "$PWM_PATH/$SUB_PATH"
    else
        echo "$PWM_PATH"
    fi
}

# Export the given pwm channel 
function pwm_create {
    local CHANNEL="$1"
    
    PWM_CHANNEL_PATH="$(pwm_get_channel_path "$CHANNEL")"
    if [ ! -d "$PWM_CHANNEL_PATH" ]; then
        echo "$CHANNEL" > "$(pwm_get_chip_path "export")"
    fi
}

# Transforms a frequency to a period
function frequency_to_period {
    local FREQUENCY="$1"

    PERC=$(awk -v freq="$FREQUENCY" 'BEGIN { printf "%.0f", 1 / freq * 1000 * 1000000; exit(0) }')
    echo "$PERC"
}

# Change the pwm duty cycle
function pwm_change_duty_cycle {
    local CHANNEL="$1"
    local FREQUENCY="$2"
    local DUTY_CYCLE="$3"

    if [ "$DUTY_CYCLE" -lt 0 ] || [ "$DUTY_CYCLE" -gt 100 ]; then
        logerr "Duty cycle must be greater or equal then 0 and lower or equal to 100"
        return 1
    fi

    PERIOD=$(frequency_to_period "$FREQUENCY")
    logdebug "f=$FREQUENCY, p=$PERIOD, dc=$DUTY_CYCLE"
    NEW_DUTY_CYCLE=$(awk -v period="$PERIOD" -v dc="$DUTY_CYCLE" 'BEGIN { printf "%.0f", period * dc / 100; exit(0) }')

    logdebug "pwm_change_duty_cycle: $NEW_DUTY_CYCLE > $(pwm_get_channel_path "$CHANNEL" "duty_cycle")"
    echo "$NEW_DUTY_CYCLE" > "$(pwm_get_channel_path "$CHANNEL" "duty_cycle")"
}

# Change the pwm frequency
function pwm_change_frequency {
    local CHANNEL="$1"
    local FREQUENCY="$2"

    if num_compare "$FREQUENCY < 0.1"; then
        logerr "Frequency can't be lower than 0.1 on the Rpi."
        return 1
    fi

    # See: https://stackoverflow.com/a/23050835/1895939
    if [ "$CURRENT_DUTY_CYCLE" == -1 ]; then
        CURRENT_DUTY_CYCLE=0
    elif [ "$CURRENT_DUTY_CYCLE" -gt 0 ]; then
        pwm_change_duty_cycle "$CHANNEL" "$FREQUENCY" "0"
    fi

    PERIOD=$(frequency_to_period "$FREQUENCY")

    logdebug "pwm_change_frequency: $PERIOD > $(pwm_get_channel_path "$CHANNEL" "period")"
    echo "$PERIOD" > "$(pwm_get_channel_path "$CHANNEL" "period")"

    pwm_change_duty_cycle "$CHANNEL" "$FREQUENCY" "$CURRENT_DUTY_CYCLE"
}

# Enable the pwm channel
function pwm_start {
    local CHANNEL="$1"
    logdebug "echo 1 > $(pwm_get_channel_path "$CHANNEL" "enable")"
    echo 1 > "$(pwm_get_channel_path "$CHANNEL" "enable")"
}

# Disable the pwm channel
function pwm_stop {
    local CHANNEL="$1"
    logdebug "echo 0 > $(pwm_get_channel_path "$CHANNEL" "enable")"
    echo 0 > "$(pwm_get_channel_path "$CHANNEL" "enable")"
}

# Validate & init the pwm
function pwm_init {
    local CHANNEL="$1"
    local FREQUENCY="$2"

    if [ ! -d "$PWM_CHIP_PATH" ]; then
        logerr "Please enable the hardware pwm by adding 'dtoverlay=pwm-2chan' to /boot/config.txt and reboot"
        exit 1
    fi

    if [ ! -w "$(pwm_get_chip_path "export")" ]; then
        logerr "Need write access to files in $PWM_CHIP_PATH"
        exit 1
    fi

    if [ "$CHANNEL" != "0" ] && [ "$CHANNEL" != "1" ]; then
        logerr "Only channel 0 and 1 are available on the Rpi"
        exit 1
    fi

    pwm_create "$CHANNEL"
    pwm_change_frequency "$CHANNEL" "$FREQUENCY"
    pwm_start "$CHANNEL"
}

# Unexport the pwm channel
function pwm_cleanup {
    local CHANNEL="$1"

    logdebug "pwm_cleanup: $CHANNEL $(pwm_get_chip_path "unexport")"
    echo "$CHANNEL" > "$(pwm_get_chip_path "unexport")"
}

# Get the raspberry pi temperature as float with 2 decimals
function get_temp {
  RAW_TEMP="$(cat /sys/class/thermal/thermal_zone0/temp)"
  TEMP="$(awk -v temp="$RAW_TEMP" 'BEGIN { printf "%0.2f", temp / 1000; exit(0) }')"
  echo "$TEMP"
}

# Main method
function __main__ {
  if [ "$AUTO_CLEANUP" -eq 1 ]; then
    trap 'pwm_cleanup $PWM_CHANNEL' EXIT
  else
    trap 'pwm_stop $PWM_CHANNEL' EXIT
  fi

  pwm_init "$PWM_CHANNEL" "$PWM_HERTZ"

  while true; do
    TEMP="$(get_temp)"
    DUTY_CYCLE=0

    printf -v CUR_TEMP %0.0f "$TEMP" # Convert float to int
    if [ "$CUR_TEMP" -ge 75 ]; then
      DUTY_CYCLE=100
    elif [ "$CUR_TEMP" -ge 70 ]; then
      DUTY_CYCLE=80
    elif [ "$CUR_TEMP" -ge 60 ]; then
      DUTY_CYCLE=70
    elif [ "$CUR_TEMP" -ge 50 ]; then
      DUTY_CYCLE=50
    elif [ "$CUR_TEMP" -ge 40 ]; then
      DUTY_CYCLE=45
    elif [ "$CUR_TEMP" -ge 25 ]; then
      DUTY_CYCLE=40
    fi

    if [ "$DUTY_CYCLE" != "$CURRENT_DUTY_CYCLE" ]; then
      pwm_change_duty_cycle "$PWM_CHANNEL" "$PWM_HERTZ" "$DUTY_CYCLE"
      CURRENT_DUTY_CYCLE="$DUTY_CYCLE"

      echo "Fan speed changed to $DUTY_CYCLE, temp is $TEMP"
    fi

    sleep "${SLEEP_INTERVAL:-5}"
  done
}

CURRENT_DUTY_CYCLE=-1

__main__


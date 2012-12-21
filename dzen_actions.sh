#!/bin/bash

export XAUTHORITY=/home/cobra/.Xauthority
export DISPLAY=:0

FONT="-*-lime-*"
TIMEOUT=1

case "$1" in
	mute)
		STATE=$(/usr/bin/amixer get Master | grep -o -E "\[on\]|\[off\]")
		case "$STATE" in
			"[on]")
				MESSAGE="Volume Unmuted"
			;;
			"[off]")
				MESSAGE="Volume Muted"
			;;
		esac
	;;
	volume_up|volume_down)
		PERCENT=$(/usr/bin/amixer get Master | grep -o -E "\[[0-9]{1,3}%\]" | tr -d '][%')
		MESSAGE="Volume: $PERCENT %"
	;;
	brightnessup|brightnessdown)
		PERCENT=$(( $(/usr/bin/xbacklight | sed "s/\.[0-9]*$//") + 1 ))
		MESSAGE="Brightness: $PERCENT %"
	;;
  echo)
    MESSAGE="$2"
  ;;
esac

echo "$MESSAGE" | dzen2 -p $TIMEOUT -fn "$FONT" &

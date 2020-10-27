#!/bin/bash

mencoder -dvd-device /dev/sr0 dvd://$1 -nosub -alang en -ovc xvid -xvidencopts bitrate=800:threads=4 -oac mp3lame -lameopts vbr=3 -o $2.avi

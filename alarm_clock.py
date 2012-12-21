#!/usr/bin/python2
import sys, os, time
from subprocess import call

if len(sys.argv) < 3:
  print("""Usage: %s HH:MM <file>""" % sys.argv[0])
  sys.exit(1)

alarm_time = sys.argv[1]
alarm_sound = sys.argv[2]

while time.strftime('%H:%M') != alarm_time:
  time.sleep(15)

call(['mplayer', '-loop', '0', alarm_sound])


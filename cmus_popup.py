#!/usr/bin/python2
import os, sys
from subprocess import call, check_output

data = check_output(['cmus-remote','-Q'])

if not data:
  print("Error with cmus get. Is it running?")
  sys.exit(1)

raw_dict = dict([
  [x[0], ' '.join(x[1:])] 
  for x in 
    [x.split() for x in data.split('\n')] 
  if len(x)
 ])

track_dict = dict([
  [x[1], ' '.join(x[2:])] 
  for x in 
    [x.split() for x in data.split('\n')] 
  if len(x) and x[0] == 'tag'
 ])

pos = round(float(raw_dict['position']) / float(raw_dict['duration']), 2)

width = 200
pwidth = round(float(width) * float(pos))
vwidth = 70

left = 70
call("""
    echo -e '^ib(1)^ro(300x100)^pa(5;5)^fg(#ccc)Artist:^pa(%i)^fg(#fff)%s^pa(5;25)^fg(#bbb)Title:^pa(%i)^fg(#fff)%s^pa(5;45)^fg(#bbb)Pos: ^pa(%i)^ro(%sx10)^pa(%i)^r(%sx10)^pa(5;65)^fg(#bbb)Vol: ^pa(%i)^ro(%sx10)^pa(%i)^r(%sx10)' \
    | dzen2 -p 3 -w 300 -h 100 -ta l -x 1060 -y 662
  """ % (
    left, track_dict['artist'], 
    left, track_dict['title'], 
    left, width, left, int(pwidth),
    left, width, left, int(vwidth)
), shell = True)


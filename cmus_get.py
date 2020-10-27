#!/usr/bin/python
import os

f = os.popen("cmus-remote -Q")
data = f.readlines()
f.close()

data_dict = {}

for each in [x.split() for x in data]:
  if each[0] == "tag" or each[0] == "set":
    each.pop(0)
  data_dict[each[0]] = " ".join(each[1:])

try:
  if data_dict['genre'] == 'Classical':
    f = os.popen("id3info "+data_dict['file'].replace(" ", "\\ "))
    data = f.readlines()
    f.close()
    for d in [x for x in data if x.startswith("===")]:
      if "Composer" in d:
        data_dict['artist'] = "".join(d.split(":")[1:]).strip()
except:
  pass

if len(data_dict['title']) > 40:
  data_dict['title'] = data_dict['title'][:40]+'...'
if len(data_dict['artist']) > 20:
  data_dict['artist'] = data_dict['artist'][:20]+'...'


position = int(float(data_dict['position']) / float(data_dict['duration']) * 100)

width = 32
height = 16

full = (width * (position / 100.0))

#status = {'playing':'^i(/home/cobra/.xmonad/icons/play.xbm)', 'paused':'^i(/home/cobra/.xmonad/icons/pause.xbm)', 'stopped':'^i(/home/cobra/.xmonad/icons/stop.xbm)'}[data_dict['status']]
status = {'playing':'>', 'paused':'=', 'stopped':'_'}[data_dict['status']]
# ^bg(#339944)^fg(black) %s ^bg() 
#print("^fg(#55FF66)(%s - %s) ^fg(#339944) ^r(%ix%i)^ro(%ix%i) %s %s%%" % (data_dict['artist'], data_dict['title'], full, height-3,  width-full, height, status, position)) 

title = data_dict['title'].replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
artist = data_dict['artist'].replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

print("(<i>%s - %s</i>) %s %s%%" % (artist, title, status, position))
#print('ARTIST="%s" TITLE="%s" STATUS="%s" LEFT="%s"' % (data_dict['artist'].replace("[","").replace("]",""), data_dict['title'].replace("[","").replace("]",""), status, position)) 


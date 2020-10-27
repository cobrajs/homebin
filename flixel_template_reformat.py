#!/usr/bin/python2

import re, sys

if len(sys.argv) < 2:
    print("Usage: %s <file>" % sys.argv[0])
    sys.exit(1)

isbracket = re.compile('^\s*\{')
elsefix = re.compile('^(\s*)(else)')

for file_name in sys.argv[1:]:
    f = open(file_name)

    out = []

    for line in f.readlines():
        if isbracket.search(line):
            out[-1] += ' {'
        else:
            match = elsefix.match(line)
            if elsefix.match(line):
                out.pop()
                line = elsefix.sub(r"\1} \2", line)
            out.append(
                line.replace('\t', '  ').rstrip()
            )

    f.close()
    f = open(file_name, 'w')
    f.write('\r\n'.join(out))
    f.close()


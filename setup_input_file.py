#!/usr/bin/env python3

import replace_lines
import sys
import os

input_file=sys.argv[1]

# Defaults
delim=':'
comment_char='#'
targ_file=None
rep_list = {}
verbose=True

with open(input_file,'r') as f:
   in_header = True
   for line_full in f.readlines():
      line = line_full.strip()
      if len(line) > 0 and (line[0] != '#'):
         # Line has content and is not a comment
         if '--- DATA ---' in line:
            # Separator to indicate start of data section
            in_header = False
            continue
         line_split = line.split('>>>')
         item_name = line_split[0].strip()
         item_val = line_split[1].strip()
         if in_header:
            if item_name == 'Comment character':
               comment_char = item_val
            elif item_name == 'Delimiter':
               delim = item_val
            elif item_name == 'Target file':
               targ_file = item_val
         else:
            rep_list[item_name] = item_val

for key, item in rep_list.items():
   print(key, item)

assert targ_file is not None, 'Output file not set'
assert os.path.isfile(targ_file), 'Output file {:s} does not exist'.format(targ_file)

replace_lines.replace_in_file(targ_file,rep_list,delim=delim,comment_char=comment_char,verbose=verbose)

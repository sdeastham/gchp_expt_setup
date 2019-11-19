#!/usr/bin/env python3

#import os
#import shutil
import sys

def replace_in_file(targ_file,rep_dict,delim=':',comment_char='#',verbose=False):
   n_changed = 0
   with open(targ_file,'r') as f:
      f_data = []
      for s in f.readlines():
         new_line = s
         if not(len(s) >= 1 and s[0] == comment_char):
            for key, item_orig in rep_dict.items():
               item = str(item_orig)
               # Ignore comment characters
               if key in new_line:
                  old_line = new_line.split(delim)
                  old_gap = ' '*(len(old_line[-1])-len(old_line[-1].lstrip()))
                  new_line = ''.join(old_line[:-1]) + delim + old_gap + item + "\n"
                  n_changed += 1
         f_data.append(new_line)
   if n_changed > 0:
      with open(targ_file,'w') as f:
         for s in f_data:
            f.write(s)
      if verbose:
         print('Changed {:d} lines in {:s}'.format(n_changed,targ_file))
   elif verbose:
      print('No changes needed in {:s}'.format(targ_file))

if __name__ == '__main__':
   # Test run - use input.geos
   comment_char='#'
   input_args=sys.argv[1:]
   is_first_run=(input_args[0]=='True')
   rep_list={'=> strat. H2O?': 'X'}
   if is_first_run:
      rep_list['=> strat. H2O?'] = 'T'
   else:
      rep_list['=> strat. H2O?'] = 'F'
   targ_file='input.geos'
   replace_in_file(targ_file,rep_list,delim=':',comment_char='#',verbose=True)

#!/usr/bin/env python3

import replace_lines
import sys

input_args=sys.argv[1:]
is_first_run=(input_args[0]=='True')
rep_list={'=> strat. H2O?': 'X'}
if is_first_run:
   rep_list['=> strat. H2O?'] = 'T'
else:
   rep_list['=> strat. H2O?'] = 'F'

replace_lines.replace_in_file('input.geos',rep_list)

#!/usr/bin/env python

import os
import calendar
import sys

if len(sys.argv) > 1:
   output_arg = sys.argv[1]
else:
   output_arg = 'short'

full_output = output_arg == 'long'
both_output = output_arg == 'both'

curr_date = None
with open('cap_restart') as fp:
    # do stuff with fp
    line = fp.readline()
    if curr_date is None:
        curr_date = line.rstrip()

#base_date = calendar.datetime.datetime(2014,7,1,0,0,0)
base_date_str = None
stop_date_str = None
with open('runConfig.sh','r') as f:
    for line in f.readlines():
        if 'Start_Time=' in line:
            base_date_str=line.split('"')[1]
        elif 'End_Time=' in line:
            stop_date_str=line.split('"')[1]
assert base_date_str is not None, 'Start date not found!'
base_date = calendar.datetime.datetime.strptime(base_date_str,'%Y%m%d %H%M%S')
stop_date = calendar.datetime.datetime.strptime(stop_date_str,'%Y%m%d %H%M%S')

#print(base_date)
curr_date = calendar.datetime.datetime.strptime(curr_date,'%Y%m%d %H%M%S')
#print(curr_date)
n_days_passed = (curr_date - base_date).days
n_days_total  = (stop_date - base_date).days

if full_output:
   print('In directory {:s}'.format(os.path.basename(os.getcwd())))
   print(' --> Simulation has reached {:s}'.format(curr_date.strftime('%Y-%m-%d')))
   print(' --> Number of days passed since {:s}: {:d}'.format(base_date.strftime('%Y-%m-%d'),n_days_passed))
   print(' --> Number of days to end date  {:s}: {:d}'.format(stop_date.strftime('%Y-%m-%d'),n_days_total))
elif both_output:
   print(n_days_passed)
   print(n_days_total)
else:
   print(n_days_passed)

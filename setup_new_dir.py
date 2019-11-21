#!/usr/bin/env python3

import shutil
import os
import sys

input_args = sys.argv[1:]

assert len(input_args)==1, 'Need exactly one argument'

dir_name = input_args[0]
name_split = dir_name.split('_')

assert len(name_split)==3, 'Directory name must take the form cNN_EXPT_SIM'
assert name_split[0][0] == 'c', 'First component must be cubed-sphere resolution as cNN'
cs_res = name_split[0][1:]
assert cs_res.isnumeric(), 'Cubed sphere resolution must be cNN, where NN[NN...] is an integer'
cs_res = int(cs_res)
expt_name = name_split[1]
sim_name = name_split[2]
setup_name = '_'.join([expt_name,sim_name])

# Default options..
cores_per_node=24
n_sim_days=1
n_sim_hours=0
if cs_res == 24:
   n_nodes = 1
elif cs_res == 48:
   n_nodes = 2
elif cs_res == 90:
   n_nodes = 8
elif cs_res == 180:
   n_nodes = 32
elif cs_res == 360:
   n_nodes = 96
else:
   raise ValueError('Settings not defined for resolution C{:d}'.format(cs_res))

assert os.path.isdir('sim_settings'), 'Directory with simulation settings not found'
assert os.path.isdir('sample_dir'), 'Sample directory sample_dir not found'
assert (not os.path.isdir(dir_name)), 'Directory already exists'

# Make the simulation directory
shutil.copytree('sample_dir',dir_name,symlinks=True)

os.chdir(dir_name)
for opts_name in ['HEMCO','GC']:
   opt_file = os.path.join('..','sim_settings',opts_name + '_options_{:s}.dat'.format(setup_name))
   if os.path.isfile(opt_file):
      os.symlink(opt_file,'{:s}_Options.dat'.format(opts_name))

util_list = ['replace_lines.py','make_output_dir.sh','setup_multi_seg.sh','reset_dir.sh','setup_simulation_opts.sh']
for f_name in util_list:
   #shutil.copy2(os.path.join('..','utils',f_name),'.')
   os.symlink(os.path.join('..','utils',f_name),f_name)

import replace_lines

# Update runConfig.sh with the correct cubed sphere resolution
rep_list = {'NUM_NODES=':n_nodes,
            'NUM_CORES_PER_NODE=':cores_per_node,
            'CS_RES=':cs_res}
replace_lines.replace_in_file('runConfig.sh',rep_list,delim='=')
rep_list = {'-n 24': '-n {:d}'.format(cores_per_node*n_nodes),
            '-N 1': '-N {:d}'.format(n_nodes),
            '-t 1-0:00': '-t {:d}-{:02d}:00:00'.format(n_sim_days,n_sim_hours),
            '-J JOB_NAME': '-J {:s}'.format(dir_name)}
replace_lines.replace_in_file('gchp.run_segment',rep_list,delim='SBATCH',comment_char='!')

os.system('./make_output_dir.sh')
os.system('../utils/setup_simulation_opts.sh True')

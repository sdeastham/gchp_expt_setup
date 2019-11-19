#!/bin/bash

if [[ $# -ne 1 ]]; then
   echo "Utility must be run with 1 input argument (True if first run, False if otherwise)"
   exit 86
fi

curr_dir=$( basename $PWD )
if [[ "$curr_dir" == "utils" ]]; then
   echo "Utility must be run in a GCHP directory"
   exit 75
fi

# Do we have Python 3 available?
which python3 &> /dev/null
if [[ $? -ne 0 ]]; then
   # Get working Python 3
   module load python/3.6.3-fasrc02
   source activate geo_scipy
fi

f_py_list=( fix_strat_H2O.py setup_input_file.py )

for f_py in "${f_py_list[@]}"; do
   cp ../utils/$f_py .
   if [[ $? -ne 0 ]]; then
      echo "Could not copy file ../utils/$f_py! Aborting"
      exit 70
   fi
done

# Set initial strat H2O if necessary
../utils/fix_strat_H2O.py $1

if [[ "$1" == "True" ]]; then
   ../utils/make_output_dir.sh
   for opt_file in HEMCO_Options.dat GC_Options.dat; do
      if [[ -e $opt_file ]]; then
         echo "Running setup options from $opt_file"
         ./setup_input_file.py $opt_file
      else
         echo "Skipping $opt_file (not found)"
      fi
   done
fi

for f_py in "${f_py_list[@]}"; do
   rm $f_py
done

exit 0

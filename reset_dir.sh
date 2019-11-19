#!/bin/bash

# Resets the current directory to a pristine state
if [[ -e cap_restart ]]; then
   rm cap_restart
fi

if [[ -d logs ]]; then
   rm logs/*
else
   mkdir logs
fi
ls slurm-* &> /dev/null
if [[ $? -ne 0 ]]; then
   mv slurm* logs/.
fi

echo "WARNING: Output directory will be cleared! Proceed? [y/n]"
valid_response=1
while [[ $valid_response -ne 0 ]]; do
   read clear_input
   if [[ "$clear_input" != "y" && "$clear_input" != "n" ]]; then
      echo "Must give y/n response"
   else
      valid_response=0
   fi
done

if [[ "$clear_input" == "n" ]]; then
   echo "Skipping output clear"
else
   date_str=$( date +%Y%m%d_%H%M )
   temp_dir=OutputDir/Archive_$date_str
   echo "Moving output to temporary storage in OutputDir/$temp_dir"
   mkdir $temp_dir
   mv OutputDir/GCHP* OutputDir/gcch* OutputDir/Output_* $temp_dir/.
fi
exit 0

#!/bin/bash

# THIS CODE TO BE RUN FIRST!
if [[ $( basename $PWD ) -ne "utils" ]]; then
   echo "This code must be in a directory called utils"
   exit 70
fi

if [[ ! -d ../sample_dir ]]; then
   echo "Missing template directory sample_dir"
   exit 75
fi

if [[ ! -e base_output_dir ]]; then
   base_dir_curr=''
   echo "No base directory information found"
   change_out_dir=y
else
   base_dir_curr=$(<base_output_dir)
   echo "Current base directory for output: $base_dir_curr"
   read -p "Would you like to change this? [y/n] " change_out_dir
fi
if [[ "$change_out_dir" == "y" ]]; then
   read -p "Please enter path to output directory: " base_dir_new
   echo $base_dir_new > base_output_dir
elif [[ "$change_out_dir" == "n" ]]; then
   echo "Output dir will remain unchanged"
   base_dir_new=$base_dir_curr
else
   echo "Must select y/n"
   exit 85
fi
if [[ "z$base_dir_new" == "z" ]]; then
   echo "Output directory not specified - aborting"
   exit 68
elif [[ ! -d $( dirname $base_dir_new ) ]]; then
   echo "Parent directory of $base_dir_new does not exist - aborting"
   exit 75
fi

internal_chk=$( cat ../sample_dir/GCHP.rc | grep '^GIGCchem_INTERNAL_CHECKPOINT_FILE' )
if [[ "$internal_chk" != *"OutputDir"* ]]; then
   echo "WARNING! Internal checkpoint file does not save to output directory!"
   echo "Recommend updating GCHP.rc in the sample_dir to fix this!"
fi

cd ..
ln -s utils/setup_new_dir.py
ln -s utils/get_n_days.py

if [[ ! -d sim_settings ]]; then
   mkdir sim_settings
fi

cp utils/sample_file.dat sim_settings/GC_options_EXPT_SIM.dat
cp utils/sample_file_HEMCO.dat sim_settings/HEMCO_options_EXPT_SIM.dat

echo "Customise (or delete, as appropriate) the files in sim_settings. "
echo "For each different simulation at ANY resolution, you can specify "
echo "unique settings in input.geos and in HEMCO_Config.rc in the files"
echo "GC_options_EXPT_SIM.dat/HEMCO_options_EXPT_SIM.dat respectively. "
echo "                                                                 "
echo "Once this is done, you can set up a new simulation using:        "
echo "./setup_new_dir.py cNN_EXPT_SIM                                  "
echo "where NN is the cubed-sphere resolution (e.g. 24, 48, 180 etc.)  "

exit 0

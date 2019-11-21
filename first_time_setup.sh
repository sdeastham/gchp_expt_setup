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

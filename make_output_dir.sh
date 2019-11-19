#!/bin/bash

# Must be set by user
base_dir=/n/scratchlfs/jacob_lab/seastham/GCHP/Output/Aviation_1262

# Derived automatically - do not change anything below this line
curr_dir=$( basename $( readlink -f . ) )
link_dir=${base_dir}/${curr_dir}

if [[ ! -d $base_dir ]]; then
   echo "Base dir does not exist (${base_dir}). Generating.."
   mkdir $base_dir
   if [[ $? != 0 ]]; then
      echo "Failed to make base directory! Aborting"
      exit 70
   fi
fi

if [[ -L OutputDir ]]; then
   if [[ $( realpath $link_dir ) == $( realpath OutputDir ) ]]; then
      echo "Output directory already linked to " $( readlink -f OutputDir )
      exit 0
   else
      echo "Output directory links to $( readlink -f OutputDir ), but expected $link_dir"
      exit 71
   fi
elif [[ -d OutputDir ]]; then
   rm -rf OutputDir
fi

if [[ -d $link_dir ]]; then
   echo "Output directory already exists - linking"
else
   mkdir $link_dir
   if [[ $? -ne 0 ]]; then
      echo "Failed to make output directory at ${link_dir}! Aborting"
      exit 72
   fi
fi

ln -s $link_dir OutputDir
if [[ $? -ne 0 ]]; then
   echo "Linking failed! Aborting"
   exit 75
fi
echo "Link to output directory established"
exit 0

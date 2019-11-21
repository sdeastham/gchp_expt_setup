#!/bin/bash

if [[ ! -e geos ]]; then
   echo "Needs to be run within GCHP run directory"
   exit 74
fi

echo "#!/bin/bash" > kill_script.sh

segment_length=15

total_days=740
n_days_run=0
prev_seg=0

if [[ $# -ge 1 ]]; then
   n_days_run=$1
fi

if [[ $# -ge 2 ]]; then
   total_days=$2
fi

i_seg=0
if [[ $# -ge 3 ]]; then
   prev_seg=$3
   i_seg=1
fi


if [[ $n_days_run == 0 && -e cap_restart ]]; then
   echo "Cap restart found!"
   exit 75
fi

if [[ ! -L OutputDir ]]; then
   ./make_output_dir.sh
fi

while [[ $n_days_run -lt $total_days ]]; do
   next_days_run=$(( $n_days_run + $segment_length ))
   printf "Running segment %5d (period: %5d - %5d)" $i_seg $n_days_run $next_days_run
   if [[ $i_seg == 0 ]]; then
      printf " --> Initial segment"
      prev_seg=$( sbatch gchp.run_segment )
   else
      printf " --> Followup"
      prev_seg=$( sbatch --dependency=afterok:${prev_seg##* } gchp.run_segment )
   fi
   printf " slurm job %d" ${prev_seg##* }
   echo ""
   i_seg=$(( $i_seg + 1 ))
   n_days_run=$next_days_run
   echo "scancel ${prev_seg##* }" >> kill_script.sh
done

chmod +x kill_script.sh

exit 0

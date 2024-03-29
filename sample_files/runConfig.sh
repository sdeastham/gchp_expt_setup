#!/bin/bash

# runSettings.sh: Update select settings in *.rc and input.geos config files
#
# Usage: source ./runConfig.sh
#
# Initial version: E. Lundgren, 8/17/2017

#------------------------------------------------
#   Compute Resources
#------------------------------------------------
# Set number of cores, number of nodes, and number of cores per node.
# Total cores must be divisible by 6. Cores per node must equal number
# of cores divided by number of nodes. Make sure you have these
# resources available.
NUM_NODES=1
NUM_CORES_PER_NODE=6
TOTAL_CORES=$(( $NUM_CORES_PER_NODE * $NUM_NODES ))

# Cores are distributed across each of the six cubed sphere faces using
# configurable parameters NX and NY. Each face is divided into NX by NY/6
# regions and each of those regions is processed by a single core 
# independent of which node it belongs to. Making NX by NY/6 as square
# as possible reduces communication overhead in GCHP.
#
# Set NXNY_AUTO to either auto-calculate NX and NY (ON) (recommended)
# or set them manually (OFF).
NXNY_AUTO=ON

# Rules and tips for setting NX and NY manually (NXNY_AUTO=OFF):
#   1. NY must be an integer and a multiple of 6	  
#   2. NX*NY must equal total number of cores (NUM_NODES*NUM_CORES_PER_NODE)
#   3. Choose NX and NY to optimize NX x NY/6 squareness 
#         Good examples: (NX=4,NY=24)  -> 96  cores at 4x4
#                        (NX=6,NY=24)  -> 144 cores at 6x4
#         Bad examples:  (NX=8,NY=12)  -> 96  cores at 8x2
#                        (NX=12,NY=12) -> 144 cores at 12x2
#   4. Domain decomposition requires that CS_RES/NX >= 4 and CS_RES*6/NY >= 4,
#      which puts an upper limit on total cores per grid resolution.
#         c24: 216 cores   (NX=6,  NY=36 )
#         c48: 864 cores   (NX=12, NY=72 )
#         c90: 3174 cores  (NX=22, NY=132)
#        c180: 12150 cores (NX=45, NY=270)
#        c360: 48600 cores (NX=90, NY=540)
#      Using fewer cores may still trigger a domain decomposition error, e.g.:
#         c48: 768 cores   (NX=16, NY=48)  --> 48/16=3 will trigger FV3 error
NX=1 # Ignore if NXNY_AUTO=ON
NY=6 # Ignore if NXNY_AUTO=ON

#------------------------------------------------
#   Internal Cubed Sphere Resolution
#------------------------------------------------
CS_RES=24 # 24 ~ 4x5, 48 ~ 2x2.5, 90 ~ 1x1.25, 180 ~ 1/2 deg, 360 ~ 1/4 deg

#------------------------------------------------
#    Debug Options
#------------------------------------------------
# Set MAPL debug flag to 0 for no extra MAPL debug log output, or 1 to
# print information to log. Using this flag is most helpful for debugging
# issues with file read (MAPL ExtData).
#
# Set memory debug flag to 0 to print memory only once per timestep. Set to
# 1 to enable memory prints at additional locations throughout the run.
#
# For GEOS-Chem debug prints, turn on ND70 in input.geos manually.       
#
# WARNING: Turning on debug prints significantly slows down the model!
#
MAPL_DEBUG_LEVEL=0
MEMORY_DEBUG_LEVEL=0

#------------------------------------------------
#    Simulation Start/End/Duration
#------------------------------------------------
# For single-segment runs, duration should be less than or equal to the
# difference between start and end time. If end time is past start time
# plus duration, the simulation will end at start time plus duration rather
# than end time.
#
# Setting duration such that two or more durations can occur between start
# and end will enable multi-segmented runs. At the end of each run the 
# end time is stored as the new start time in output file cap_restart.
# Rerunning without removing or editing cap_restart will start at the
# start time in cap_restart rather than the start time listed below. 
# Use this feature with the multi-segmented runs / monthly diagnostics
# section below. See more information about this on the GCHP wiki.
#
Start_Time="20140701 000000"
End_Time="20160701 000000"
Duration="00000015 000000"

#------------------------------------------------
#    Diagnostics
#------------------------------------------------        
# Frequency, duration, and mode used for all default HISTORY.rc diagnostic
# collections are set from within this file. These are defined as:
#
#   Frequency = frequency of diagnostic calculation (HHmmSS)
#   Duration  = frequency of diagnostic file  write (HHmmSS)
#   Mode      = computation of diagnostics (time-averaged or instantaneous)
#
# Edit the frequency, duration, and mode below to change global settings.
# See the list further below of what HISTORY.rc collections will be updated.
# 
# NOTES: 
#  1. Freq and duration hours may exceed 2 digits, e.g. 7440000 for 31 days
#  2. Freq and duration are ignored if Monthly_Diag is set to 1
#  3. If you do not want settings for certain collections set automatically
#     from this file, comment them out below.
#  4. If you add a collection to HISTORY.rc and want its settings
#     automatically updated from this file, add to the list below.
#  5. To turn off collections completely, comment them out in HISTORY.rc.
#
common_freq="010000"          # Ignore if using multi-run monthly diag option
common_dur="010000"           # Ignore if using multi-run monthly diag option
common_mode="'time-averaged'" # "'time-averaged'" and "'instantaneous'"

SpeciesConc_freq=${common_freq}
SpeciesConc_dur=${common_dur}
SpeciesConc_mode=${common_mode}
AerosolMass_freq=${common_freq}
AerosolMass_dur=${common_dur}
AerosolMass_mode=${common_mode}
Aerosols_freq=${common_freq}
Aerosols_dur=${common_dur}
Aerosols_mode=${common_mode}
Budget_freq=${common_freq}
Budget_dur=${common_dur}
Budget_mode=${common_mode}
CloudConvFlux_freq=${common_freq}
CloudConvFlux_dur=${common_dur}
CloudConvFlux_mode=${common_mode}
ConcAboveSfc_freq=${common_freq}
ConcAboveSfc_dur=${common_dur}
ConcAboveSfc_mode="'instantaneous'"
ConcAfterChem_freq=${common_freq}
ConcAfterChem_dur=${common_dur}
ConcAfterChem_mode=${common_mode}
DryDep_freq=${common_freq}
DryDep_dur=${common_dur}
DryDep_mode=${common_mode}
Emissions_freq=${common_freq}
Emissions_dur=${common_dur}
Emissions_mode=${common_mode}
JValues_freq=${common_freq}
JValues_dur=${common_dur}
JValues_mode=${common_mode}
JValuesLocalNoon_freq=${common_freq}
JValuesLocalNoon_dur=${common_dur}
JValuesLocalNoon_mode=${common_mode}
LevelEdgeDiags_freq=${common_freq}
LevelEdgeDiags_dur=${common_dur}
LevelEdgeDiags_mode=${common_mode}
ProdLoss_freq=${common_freq}
ProdLoss_dur=${common_dur}
ProdLoss_mode=${common_mode}
RadioNuclide_freq=${common_freq}
RadioNuclide_dur=${common_dur}
RadioNuclide_mode=${common_mode}
StateChm_freq=${common_freq}
StateChm_dur=${common_dur}
StateChm_mode=${common_mode}
StateMet_avg_freq=${common_freq}
StateMet_avg_dur=${common_dur}
StateMet_avg_mode=${common_mode}
StateMet_inst_freq=${common_freq}
StateMet_inst_dur=${common_dur}
StateMet_inst_mode="'instantaneous'"
Transport_freq=${common_freq}
Transport_dur=${common_dur}
Transport_mode="'instantaneous'"
WetLossConv_freq=${common_freq}
WetLossConv_dur=${common_dur}
WetLossConv_mode=${common_mode}
WetLossLS_freq=${common_freq}
WetLossLS_dur=${common_dur}
WetLossLS_mode=${common_mode}

#------------------------------------------------
#    Initial Restart File
#------------------------------------------------
# By default the linked restart files in the run directories will be 
# used. Please note that HEMCO restart variables are stored in the same
# restart file as species concentrations. Initial restart files available 
# on gcgrid do not contain HEMCO variables which will have the same effect
# as turning the HEMCO restart file option off in GC classic. However, all 
# output restart files will contain HEMCO restart variables for your next run.
#INITIAL_RESTART=initial_GEOSChem_rst.c${CS_RES}_standard.nc
INITIAL_RESTART=GEOSChem_restart_link.nc

# You can specify a custom initial restart file here to overwrite:
# INITIAL_RESTART=your_restart_filename_here

#------------------------------------------------
#    Output Restart Files
#------------------------------------------------
# You can output restart files at regular intervals throughout your
# simulation. These restarts are in addition to the end-of-run restart
# which is always produced. To configure output restart file frequency,
# set the variable below to a string of format HHmmSS. More than 2
# digits for the hours string is permitted (e.g. 1680000 for 7 days).
# Setting the frequency to 000000 will turn off this feature by setting
# it to a very large number.
Checkpoint_Freq="000000"

#------------------------------------------------
#    Turn Components On/Off
#------------------------------------------------
# Automatically turns on/off GEOS-Chem components in input.geos.
#
# WARNING: these settings will override manual updates you make to input.geos!
#
Turn_on_Chemistry=T
Turn_on_emissions=T
Turn_on_Dry_Deposition=T
Turn_on_Wet_Deposition=T
Turn_on_Transport=T
Turn_on_Cloud_Conv=T
Turn_on_PBL_Mixing=T
Turn_on_Non_Local_Mixing=T

#------------------------------------------------
#    Timesteps
#------------------------------------------------
# Optimal timesteps are dependent on grid resolution and are automatically
# set based on the GCHP Working Group's recommendation below. To override
# these settings, comment out the code and manually define the following
# variables:
#    ChemEmiss_Timestep_sec     : chemistry timestep interval [s]
#    TransConv_Timestep_sec     : dynamic timestep interval [s]
#    TransConv_Timestep_HHMMSS  : dynamic timestep interval as HHMMSS string
#
# WARNING: Settings in this file will override settings in input.geos!
#
# NOTE: Default timesteps for c24 and c48, the cubed-sphere rough equivalents
# of 4x5 and 2x2.5, are the same as defaults timesteps in GEOS-Chem Classic
#
if [[ $CS_RES -lt 180 ]]; then
    ChemEmiss_Timestep_sec=1200
    TransConv_Timestep_sec=600
    TransConv_Timestep_HHMMSS=001000
else
    ChemEmiss_Timestep_sec=600
    TransConv_Timestep_sec=300
    TransConv_Timestep_HHMMSS=000500
fi

#------------------------------------------------
#    Multi-run option
#------------------------------------------------        
# The simplest run is a single segment. Set Num_Runs=1 and Monthly_Diag=0.
#
# In some cases it is advantageous to split up your simulation into 
# multiple runs, what we call the multi-run option. Use this option as follows:
#   1. Set Num_Runs below to total # of consecutive runs
#   2. Set Monthly_Diag=1 to output monthly diagnostics; else 0.
#   3. Copy gchp.multirun.sh and gchp.multirun.run from runScriptSamples/
#      to run directory
#   4. Configure resources at the top of gchp.multirun.run (assumes SLURM).
#      This is the run script used for each individual run in the sequence.
#   5. Set duration above to the duration of each INDIVIDUAL run
#   6. Set end date after start date to span ALL runs
#   7. Execute shell script gchp.multirun.sh at the command line
#         $ ./gchp.multirun.sh
#
# When using monthly diagnostics:
#   - Run segment duration must be 1-month (00000100 000000)
#   - Start date must be within the first 28 days of the month
#   - There is no need to set diag frequency and duration in this file
#     since they will be over-written for each run based on days in month
#
Num_Runs=1
Monthly_Diag=0

##########################################################
##########################################################
####        END OF CONFIGURABLES SECTION
##########################################################
##########################################################

###############################
####   QUALITY CHECKS
###############################

#### Check that resource allocation makes sense
if (( ${TOTAL_CORES}%6 != 0 )); then
   echo "ERROR: TOTAL_CORES must be divisible by 6. Update value in runConfig.sh."
   exit 1    
fi
if (( ${TOTAL_CORES} != ${NUM_NODES}*${NUM_CORES_PER_NODE} )); then
   echo "ERROR: TOTAL_CORES must equal to NUM_NODES times NUM_CORES_PER_NODE. Update values in runConfig.sh."
   exit 1    
fi

#### If on, auto-calculate NX and NY to maximize squareness of core regions
if [[ ${NXNY_AUTO} == 'ON' ]]; then
   Z=$(( ${NUM_NODES}*${NUM_CORES_PER_NODE}/6 ))
   SQRT=$(echo "sqrt (${Z})" | bc -l)  
   N=$(echo $SQRT | awk '{print int($1+0.999)}')
   while [[ "${N}" > 0 ]]; do
      if (( ${Z} % ${N} == 0 )); then
         NX=${N}
         NY=$((${Z}/${N}*6))
         break
      else
         N=$((${N}-1))
      fi
   done
fi

#### Check that NX and NY make sense
if (( ${NX}*${NY} != ${TOTAL_CORES} )); then
   echo "ERROR: NX*NY must equal TOTAL_CORES. Check values in runConfig.sh."
   exit 1    
fi
if (( ${NY}%6 != 0 )); then
   echo "ERROR: NY must be an integer divisible by 6. Check values in runConfig.sh."
   exit 1    
fi

#### Check that domain decomposition will not trigger a FV3 domain error
if [[ $(( ${CS_RES}/${NX} )) -lt 4 || $(( ${CS_RES}*6/${NY} )) -lt 4  ]]; then
   echo "ERROR: NX and NY are set such that face side length divided by NX or NY/6 is less than 4. The cubed sphere compute domain has a minimum requirement of 4 points in NX and NY/6. Adjust total number of cores in runConfig.sh."
   exit 1
fi

#### Check if domains are square enough (NOTE: approx using integer division)
if [[ $(( ${NX}*6/${NY}*2 )) -ge 5 || $(( ${NY}/${NX}/6*2 )) -ge 5 ]] ; then
    echo "WARNING: NX and NY are set such that NX x NY/6 has side ratio >= 2.5. Consider adjusting resources in runConfig.sh to be more square. This will avoid negative effects due to excessive communication between cores."
fi

#### Give error if chem timestep is < dynamic timestep
if [[ ${ChemEmiss_Timestep_sec} -lt ${TransConv_Timestep_sec} ]]; then
    echo "ERROR: chemistry timestep must be >= dynamic timestep. Update values in runConfig.sh."
    exit 1
fi

## Check if restart file exists
if [[ ! -e ${INITIAL_RESTART} ]]; then
    printf 'ERROR: Restart file specified in runConfig.sh not found: %s\n' ${INITIAL_RESTART}
    exit 1
fi

#### Check transport setting. If okay, set binary indicator
if [[ ${Turn_on_Transport} == 'T' ]]; then
    ADVCORE_ADVECTION=1
elif [[ ${Turn_on_Transport} == 'F' ]]; then
    ADVCORE_ADVECTION=0
else
    echo "ERROR: Incorrect transport setting"
    exit 1
fi

##########################################
####   DEFINE FUNCTIONS TO UPDATE FILES
##########################################

#### Define function to replace values in .rc files
replace_val() {
    KEY=$1
    VALUE=$2
    FILE=$3
    printf '%-30s : %-20s %-20s\n' "${KEY//\\}" "${VALUE}" "${FILE}"

    # replace value in line starting with 'whitespace + key + whitespace + : +
    # whitespace + value' where whitespace is variable length including none
    sed "s|^\([\t ]*${KEY}[\t ]*:[\t ]*\).*|\1${VALUE}|" ${FILE} > tmp
    mv tmp ${FILE}
}

#### Define function to replace met-field read frequency in ExtData.rc
update_dyn_freq() {

    # Check number of matches. Should be one; otherwise exit with an error.
    numlines=$(grep -c "$1.*MetDir" $2)
    if [[ ${numlines} == "0" ]]; then
       echo "ERROR: met-field $1 missing in $2"
       #exit 1
    elif [[ ${numlines} > 1 ]]; then
       echo "ERROR: more than one entry in $1 in $2. Reduce to one so that read frequency can be auto-synced with dynamic timestep from runConfig.sh."
       exit 1
    fi
    
    # Get line number
    x=$(grep -n "$1.*MetDir" $2)
    linenum=${x%%:*}
    
    # Get current ExtData.rc frequency read string
    x=$(grep "$1.*MetDir" $2)
    z=${x%%;*}
    charnum=${#z}
    currentstr=${x[0]:${charnum}+1:6}
    
    # Replace string with configured dynamic timestep
    sed -i "${linenum}s/${currentstr}/${TransConv_Timestep_HHMMSS}/" $2

    # Print what just happened
    printf '%-30s : %-20s %-20s\n' "$1 read frequency" "0;${TransConv_Timestep_HHMMSS}" "$2"
}

###############################
####   UPDATE FILES
###############################

#### Set # nodes, # cores, and shared memory option
echo "Compute resources:"
replace_val NX            ${NX}                 GCHP.rc
replace_val NY            ${NY}                 GCHP.rc
replace_val CoresPerNode  ${NUM_CORES_PER_NODE} HISTORY.rc

####  set cubed-sphere resolution and related grid variables
echo " "
echo "Cubed-sphere resolution:"
CS_RES_x_6=$((CS_RES*6))
replace_val GCHP.IM_WORLD  ${CS_RES}                     GCHP.rc
replace_val GCHP.IM        ${CS_RES}                     GCHP.rc
replace_val GCHP.JM        ${CS_RES_x_6}                 GCHP.rc
replace_val IM             ${CS_RES}                     GCHP.rc
replace_val JM             ${CS_RES_x_6}                 GCHP.rc
replace_val npx            ${CS_RES}                     fvcore_layout.rc
replace_val npy            ${CS_RES}                     fvcore_layout.rc
replace_val GCHP.GRIDNAME  PE${CS_RES}x${CS_RES_x_6}-CF  GCHP.rc

####  set input restart filename
echo " "
echo "Initial restart file:"
replace_val GIGCchem_INTERNAL_RESTART_FILE "+${INITIAL_RESTART}" GCHP.rc

#### Set simulation start and end datetimes based on input.geos
echo " "
echo "Simulation start, end, duration:"
replace_val BEG_DATE  "${Start_Time}" CAP.rc
replace_val END_DATE  "${End_Time}"   CAP.rc
replace_val JOB_SGMT  "${Duration}"   CAP.rc

#### Set frequency of writing restart files
# Set to a very large number if turned off
if [[ ${Checkpoint_Freq} == '000000' ]]; then
   Checkpoint_Freq=100000000
fi 
echo " "
echo "Checkpoint (restart) frequency:"
replace_val RECORD_FREQUENCY "${Checkpoint_Freq}" GCHP.rc
replace_val RECORD_REF_DATE  "${Start_Time:0:8}"  GCHP.rc
replace_val RECORD_REF_TIME  "${Start_Time:9:6}"  GCHP.rc

#### Set output frequency, duration, and mode
echo " "
echo "Output:" 
replace_val SpeciesConc.frequency      ${SpeciesConc_freq}      HISTORY.rc  
replace_val SpeciesConc.duration       ${SpeciesConc_dur}       HISTORY.rc
replace_val SpeciesConc.mode           ${SpeciesConc_mode}      HISTORY.rc
replace_val StateMet_avg.frequency     ${StateMet_avg_freq}	HISTORY.rc
replace_val StateMet_avg.duration      ${StateMet_avg_dur}	HISTORY.rc
replace_val StateMet_avg.mode          ${StateMet_avg_mode}	HISTORY.rc
replace_val StateMet_inst.frequency    ${StateMet_inst_freq}	HISTORY.rc
replace_val StateMet_inst.duration     ${StateMet_inst_dur}	HISTORY.rc
replace_val StateMet_inst.mode         ${StateMet_inst_mode}	HISTORY.rc
replace_val AerosolMass.frequency      ${AerosolMass_freq}      HISTORY.rc
replace_val AerosolMass.duration       ${AerosolMass_dur}       HISTORY.rc
replace_val AerosolMass.mode           ${AerosolMass_mode}      HISTORY.rc
replace_val Aerosols.frequency         ${Aerosols_freq}	        HISTORY.rc
replace_val Aerosols.duration          ${Aerosols_dur}	        HISTORY.rc
replace_val Aerosols.mode              ${Aerosols_mode}	        HISTORY.rc
replace_val Budget.frequency           ${Budget_freq}	        HISTORY.rc
replace_val Budget.duration            ${Budget_dur}	        HISTORY.rc
replace_val Budget.mode                ${Budget_mode}	        HISTORY.rc
replace_val CloudConvFlux.frequency    ${CloudConvFlux_freq}    HISTORY.rc
replace_val CloudConvFlux.duration     ${CloudConvFlux_dur}     HISTORY.rc
replace_val CloudConvFlux.mode         ${CloudConvFlux_mode}    HISTORY.rc
replace_val ConcAboveSfc.frequency     ${ConcAboveSfc_freq}     HISTORY.rc
replace_val ConcAboveSfc.duration      ${ConcAboveSfc_dur}      HISTORY.rc
replace_val ConcAboveSfc.mode          ${ConcAboveSfc_mode}     HISTORY.rc
replace_val ConcAfterChem.frequency    ${ConcAfterChem_freq}    HISTORY.rc
replace_val ConcAfterChem.duration     ${ConcAfterChem_dur}     HISTORY.rc
replace_val ConcAfterChem.mode         ${ConcAfterChem_mode}    HISTORY.rc
replace_val DryDep.frequency           ${DryDep_freq}	        HISTORY.rc
replace_val DryDep.duration            ${DryDep_dur}	        HISTORY.rc
replace_val DryDep.mode                ${DryDep_mode}	        HISTORY.rc
replace_val Emissions.frequency        ${Emissions_freq}        HISTORY.rc
replace_val Emissions.duration         ${Emissions_dur}	        HISTORY.rc
replace_val Emissions.mode             ${Emissions_mode}	HISTORY.rc
replace_val JValues.frequency          ${JValues_freq}	        HISTORY.rc
replace_val JValues.duration           ${JValues_dur}	        HISTORY.rc
replace_val JValues.mode               ${JValues_mode}	        HISTORY.rc
replace_val JValuesLocalNoon.frequency ${JValuesLocalNoon_freq} HISTORY.rc
replace_val JValuesLocalNoon.duration  ${JValuesLocalNoon_dur}  HISTORY.rc
replace_val JValuesLocalNoon.mode      ${JValuesLocalNoon_mode} HISTORY.rc
replace_val LevelEdgeDiags.frequency   ${LevelEdgeDiags_freq}   HISTORY.rc
replace_val LevelEdgeDiags.duration    ${LevelEdgeDiags_dur}    HISTORY.rc
replace_val LevelEdgeDiags.mode        ${LevelEdgeDiags_mode}   HISTORY.rc
replace_val ProdLoss.frequency         ${ProdLoss_freq}         HISTORY.rc
replace_val ProdLoss.duration          ${ProdLoss_dur}          HISTORY.rc
replace_val ProdLoss.mode              ${ProdLoss_mode}         HISTORY.rc
replace_val RadioNuclide.frequency     ${RadioNuclide_freq}     HISTORY.rc
replace_val RadioNuclide.duration      ${RadioNuclide_dur}      HISTORY.rc
replace_val RadioNuclide.mode          ${RadioNuclide_mode}     HISTORY.rc
replace_val StateChm.frequency         ${StateChm_freq}	        HISTORY.rc
replace_val StateChm.duration          ${StateChm_dur}	        HISTORY.rc
replace_val StateChm.mode              ${StateChm_mode}	        HISTORY.rc
replace_val Transport.frequency        ${Transport_freq}	HISTORY.rc
replace_val Transport.duration         ${Transport_dur}	        HISTORY.rc
replace_val Transport.mode             ${Transport_mode}	HISTORY.rc
replace_val WetLossConv.frequency      ${WetLossConv_freq}      HISTORY.rc
replace_val WetLossConv.duration       ${WetLossConv_dur}       HISTORY.rc
replace_val WetLossConv.mode           ${WetLossConv_mode}      HISTORY.rc
replace_val WetLossLS.frequency        ${WetLossLS_freq}        HISTORY.rc
replace_val WetLossLS.duration         ${WetLossLS_dur}         HISTORY.rc  
replace_val WetLossLS.mode             ${WetLossLS_mode}        HISTORY.rc  

#### Set timesteps. This includes updating ExtData.rc entries for PS2,
#### SPHU2, and TMPU2 such that read frequency matches dynamic frequency
echo " "
echo "Timesteps:"
replace_val HEARTBEAT_DT  ${TransConv_Timestep_sec}  GCHP.rc
replace_val SOLAR_DT      ${TransConv_Timestep_sec}  GCHP.rc
replace_val IRRAD_DT      ${TransConv_Timestep_sec}  GCHP.rc
replace_val RUN_DT        ${TransConv_Timestep_sec}  GCHP.rc
replace_val GIGCchem_DT   ${ChemEmiss_Timestep_sec}  GCHP.rc
replace_val DYNAMICS_DT   ${TransConv_Timestep_sec}  GCHP.rc
replace_val HEARTBEAT_DT  ${TransConv_Timestep_sec}  CAP.rc
replace_val dt            ${TransConv_Timestep_sec}  fvcore_layout.rc
update_dyn_freq PS2   ExtData.rc
update_dyn_freq SPHU2 ExtData.rc
update_dyn_freq TMPU2 ExtData.rc

#### Set debug level
echo " "
echo "Debug levels:"
replace_val DEBUG_LEVEL ${MAPL_DEBUG_LEVEL} ExtData.rc
replace_val MEMORY_DEBUG_LEVEL ${MEMORY_DEBUG_LEVEL} GCHP.rc

##### Set commonly changed settings in input.geos
echo " "
echo "Components on/off:"
replace_val "Turn on Chemistry?"        ${Turn_on_Chemistry}        input.geos
replace_val "Turn on emissions?"	${Turn_on_emissions}        input.geos
replace_val "Turn on Transport"	        ${Turn_on_Transport}        input.geos
replace_val "Turn on Cloud Conv?"	${Turn_on_Cloud_Conv}       input.geos
replace_val "Turn on PBL Mixing?"	${Turn_on_PBL_Mixing}       input.geos
replace_val " => Use non-local PBL?"	${Turn_on_Non_Local_Mixing} input.geos
replace_val "Turn on Dry Deposition?"   ${Turn_on_Dry_Deposition}   input.geos
replace_val "Turn on Wet Deposition?"   ${Turn_on_Wet_Deposition}   input.geos
replace_val AdvCore_Advection           ${ADVCORE_ADVECTION}        GCHP.rc
echo " "
echo "Timesteps:"
replace_val "Tran\/conv timestep \[sec\]"  ${TransConv_Timestep_sec}   input.geos
replace_val "Chem\/emis timestep \[sec\]"  ${ChemEmiss_Timestep_sec}   input.geos
	    




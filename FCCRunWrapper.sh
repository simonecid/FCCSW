#!/bin/bash
# Sandbox home directory, used to save output file
SAVE_DEST="$(pwd)"

nEvents=1

while getopts "j:c:p:" o; do
  case "${o}" in
    j)
      jobName=${OPTARG}
      ;;
    c)
      clusterId=${OPTARG}
      ;;
    p)
      processId=${OPTARG}
      ;;
    esac
done

randomNumberSeed=$(((clusterId+processId)%900000000))
# Ugly workaround to setup seed
echo "Random:seed = ${randomNumberSeed}" >> ${SAVE_DEST}/Pythia_minbias_pp_100TeV.cmd
cd /software/sb17498/FCCSW
source init.sh
./run fccrun.py /software/sb17498/FCCSW/Sim/SimDelphesInterface/options/PythiaDelphes_config.py --outputfile=${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root --inputfile=${SAVE_DEST}/Pythia_minbias_pp_100TeV.cmd --nevents=${nEvents}
#echo ${randomNumberSeed}
#echo "${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root"
#!/bin/bash
# Sandbox home directory, used to save output file
SAVE_DEST="$(pwd)"

nEvents=5000

# Destination in /HDFS/FCC-hh
HDFS_DEST="HardQCD_PtBinned_500_700_GeV"
inputFile="Pythia_HardQCD_500_700.cmd"
software="/software/sb17498/FCCSW/Generation/data"

while getopts "j:c:p:i:n:" o; do
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
    i)
      inputFile=${OPTARG}
      ;;
    n) 
      nEvents=${OPTARG}
      ;;
    esac
done

cp ${software}/${inputFile} ${SAVE_DEST}/${inputFile}

randomNumberSeed=$(((clusterId+processId)%900000000))
# Ugly workaround to setup seed
printf "\nRandom:seed = ${randomNumberSeed}\n" >> ${SAVE_DEST}/${inputFile}
cd /software/sb17498/FCCSW
source init.sh
./run fccrun.py /software/sb17498/FCCSW/Sim/SimDelphesInterface/options/PythiaDelphes_config_CMS.py --outputfile=${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root --inputfile=${SAVE_DEST}/${inputFile} --nevents=${nEvents}
#echo ${randomNumberSeed}
echo "${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root"

set -o xtrace

/usr/bin/hdfs dfs -mkdir -p /FCC-hh/${HDFS_DEST}
/usr/bin/hdfs dfs -moveFromLocal ${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root /FCC-hh/${HDFS_DEST}

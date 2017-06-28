#!/bin/bash
# Sandbox home directory, used to save output file
SAVE_DEST="$(pwd)"

nEvents=5000

# Destination in /HDFS/FCC-hh
inputFile="Pythia_HardQCD_700_900.cmd"
software="/software/sb17498/FCCSW/"
config="Sim/SimDelphesInterface/options/PythiaDelphes_config_CMS.py"

while getopts "j:c:p:i:n:s:d:" o; do
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
    s)
      config=${OPTARG}
      ;;
    d)
      HDFS_DEST=${OPTARG}
      ;;
    esac
done

cp ${software}Generation/data/${inputFile} ${SAVE_DEST}/${inputFile}

randomNumberSeed=$(((clusterId+processId)%900000000))
# Ugly workaround to setup seed
printf "\nRandom:seed = ${randomNumberSeed}\n" >> ${SAVE_DEST}/${inputFile}
cd /software/sb17498/FCCSW
source init.sh
set -o xtrace
./run fccrun.py ${software}${config} --outputfile=${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root --inputfile=${SAVE_DEST}/${inputFile} --nevents=${nEvents}
#echo ${randomNumberSeed}
echo "${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root"

/usr/bin/hdfs dfs -mkdir -p /FCC-hh/${HDFS_DEST}
/usr/bin/hdfs dfs -moveFromLocal ${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root /FCC-hh/${HDFS_DEST}

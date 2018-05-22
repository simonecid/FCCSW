#!/bin/bash
# Sandbox home directory, used to save output file
SAVE_DEST="$(pwd)"

nEvents=5000

# Destination in /HDFS/FCC-hh
inputFile="Pythia_HardQCD_700_900.cmd"
software="/software/sb17498/FCCSW"
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

set -o xtrace

git clone https://www.github.com/simonecid/FCCSW

cd FCCSW
set +o xtrace
source init.sh
set -o xtrace
make -j4

# We have to setup the seed, therefore we create an individual copy of the pythia cmd and we will append its seed to it
randomNumberSeed=$(((clusterId+processId)%900000000))
printf "\nRandom:seed = ${randomNumberSeed}\n" >> Generation/data/${inputFile}
printf "\nRandom:seed = ${randomNumberSeed}\n"

echo "I am running on" $HOSTNAME

# Running the sim
./run fccrun.py ${software}/${config} --outputfile=${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root --inputfile=Generation/data/${inputFile} --nevents=${nEvents}
echo "${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root"

# Copying output
/usr/bin/hdfs dfs -mkdir -p /FCC-hh/${HDFS_DEST}
/usr/bin/hdfs dfs -moveFromLocal ${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root /FCC-hh/${HDFS_DEST}

# Removing cmd to avoid a copy in the submission folder
set +o xtrace
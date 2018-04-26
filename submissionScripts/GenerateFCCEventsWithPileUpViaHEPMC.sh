#!/bin/bash
# Sandbox home directory, used to save output file
SAVE_DEST="$(pwd)"

nEvents=5000

# Destination in /HDFS/FCC-hh
software="/software/sb17498/FCCSW"
config="Sim/SimDelphesInterface/options/PythiaDelphes_config_CMS.py"

while getopts "j:c:p:i:n:s:d:p:" o; do
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
    p)
      NUMBER_OF_PYTHIA_EVENTS=${OPTARG}
    esac
done

set -o xtrace

echo "I am running on" $HOSTNAME

# building fcc env
git clone https://www.github.com/simonecid/FCCSW
cd FCCSW
set +o xtrace
source init.sh
set -o xtrace
make -j4

#creating the hepmc events
/software/sb17498/pythia8223/pythia-FCC/generateEventsToHepMC.exe -c /software/sb17498/pythia8223/pythia-FCC/${inputFile} -o ${SAVE_DEST}/events.hepmc -n ${NUMBER_OF_PYTHIA_EVENTS} -s $(((clusterId+processId)%900000000))

#exporting to .pileup format
/cvmfs/fcc.cern.ch/testing/lcgview/LCG_92/x86_64-slc6-gcc62-opt/bin/hepmc2pileup Minbias.pileup ${SAVE_DEST}/events.hepmc

#deleting old hepmc
rm ${SAVE_DEST}/events.hepmc

#running the delphes sim
./run fccrun.py ${software}/${config} --outputfile=${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root --inputfile=${SAVE_DEST}/${inputFile} --nevents=${nEvents}
echo "${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root"

rm Minbias.pileup

# Copying output
/usr/bin/hdfs dfs -mkdir -p /FCC-hh/${HDFS_DEST}
/usr/bin/hdfs dfs -moveFromLocal ${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root /FCC-hh/${HDFS_DEST}

# Removing cmd to avoid a copy in the submission folder
rm ${SAVE_DEST}/${inputFile}
set +o xtrace
#!/bin/bash
# Sandbox home directory, used to save output file
SAVE_DEST="$(pwd)"

nEvents=5000

# Destination in /HDFS/FCC-hh
software="/software/sb17498/FCCSW"
config="Sim/SimDelphesInterface/options/PythiaDelphes_config_CMS.py"

while getopts "j:c:p:i:n:s:d:m:" o; do
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

echo "I am running on" $HOSTNAME

#setup_gcc
source /cvmfs/sft.cern.ch/lcg/contrib/gcc/4.9/x86_64-slc6/setup.sh
#setup_root
source /cvmfs/sft.cern.ch/lcg/releases/ROOT/6.08.06-c8fb4/x86_64-slc6-gcc49-opt/bin/thisroot.sh

#creating the hepmc events
/software/sb17498/pythia8223/pythia-FCC/generateEventsToHepMC.exe -c /software/sb17498/pythia8223/pythia-FCC/${inputFile} -o ${SAVE_DEST}/events.hepmc -n ${nEvents} -s $(((clusterId+processId)%900000000))

# building fcc env
git clone https://www.github.com/simonecid/FCCSW
cd FCCSW
set +o xtrace
source init.sh
set -o xtrace
make -j4


#running the delphes sim
./run fccrun.py ${config} --outputfile=${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root --inputfile=${SAVE_DEST}/events.hepmc --nevents=${nEvents}
echo "${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root"

rm ${SAVE_DEST}/events.hepmc

# Copying output
/usr/bin/hdfs dfs -mkdir -p /FCC-hh/${HDFS_DEST}
/usr/bin/hdfs dfs -moveFromLocal ${SAVE_DEST}/events_${jobName}_${clusterId}.${processId}.root /FCC-hh/${HDFS_DEST}

set +o xtrace
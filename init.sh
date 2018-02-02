
#!/bin/sh -u
# set FCCSWBASEDIR to the directory containing this script
export FCCSWBASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
weekday=`date +%a`
source /cvmfs/fcc.cern.ch/testing/sw/views/stable/x86_64-slc6-gcc62-opt/setup.sh
export DELPHES_DIR=../Delphes_install
export CMAKE_PREFIX_PATH=../Delphes_install:$CMAKE_PREFIX_PATH
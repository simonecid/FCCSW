#!/bin/sh -u
#Adding miniconda env w/ ipython 
source activate FCCSW # miniconda environment w/ ipython
# set FCCSWBASEDIR to the directory containing this script
export FCCSWBASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source /cvmfs/fcc.cern.ch/sw/0.8.1/init_fcc_stack.sh $1
#CUSTOM: adding miniconda stuff for matplotlib
export PATH="/software/miniconda/bin:$PATH"
#Removing LCG ipython to use miniconda's one
export PATH=`python /opt/scripts/remove_from_path.py $PATH /cvmfs/sft.cern.ch/lcg/views/LCG_88/x86_64-slc6-gcc49-opt/bin` # Removed LCG from path (ipython)

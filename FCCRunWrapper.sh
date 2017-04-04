#!/bin/bash
cd /software/sb17498/FCCSW
source init.sh
./run fccrun.py /software/sb17498/FCCSW/Sim/SimDelphesInterface/options/PythiaDelphes_config.py --outputfile=1event_100TeV.root --inputfile=/software/sb17498/FCCSW/Generation/data/Pythia_minbias_pp_100TeV.cmd --nevents=1
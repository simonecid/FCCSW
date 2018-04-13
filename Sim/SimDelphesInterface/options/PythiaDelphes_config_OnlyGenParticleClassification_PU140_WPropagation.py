## \file
## \ingroup SimulationExamples
## \author Z. Drasal (CERN)
## \brief FCCSw Pythia-->Delphes simulation options file
##
##
##  - GAUDI run in a mode: Pythia + Delphes or Delphes only (if delphesHepMCInFile defined)
##  - define variables & delphes sim outputs
##
##  - inputs:
##    * Define pythiaConfFile -> configure Pythia parameters & input (simulate or read LHE file)
##    * Define delphesCard -> describe detector response & configure Delphes - process modules, detector parameters etc.
##    * Define delphesHepMCInFile -> read Delphes input from hepMC file (if Pythia not used)
##    * Undefine ("") delphesHepMCInFile -> read Delphes input from GAUDI data store
##
##  - outputs:
##    * Define delphesRootOutFile -> write output using Delphes I/O library (Delphes objects)
##    * Undefine ("") delphesRootOutFile -> no output using Delphes I/O library
##    * Define out module to write output using FCC-EDM lib (standard FCC output)
##
##  - run:
##    * ./run fccrun.py Sim/SimDelphesInterface/options/PythiaDelphes_config.py
##

"""
To run Pythia together with Delphes
> ./run gaudirun.py Sim/SimDelphesInterface/options/PythiaDelphes_config.py
"""
import sys
from Gaudi.Configuration import *

from Configurables import ApplicationMgr, FCCDataSvc
from Configurables import DelphesSaveGenJets, DelphesSaveJets, DelphesSaveMet
from Configurables import DelphesSaveNeutralParticles, DelphesSaveChargedParticles


def apply_paths(obj, names):
  """ Applies the collection names to the Paths of DataOutputs """
  for attr, name in names.iteritems():
    getattr(obj, attr).Path = name


import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--delphescard', type=str, default=None, help='specify an input delphes card')
delphes_args, _ = parser.parse_known_args()

from FWCore.joboptions import parse_standard_job_options
args = parse_standard_job_options()

############################################################
#
# User: Configure variables
#
############################################################

## N-events
nEvents=100
if args.nevents is not None:
    nEvents = args.nevents

## Message level
messageLevelPythia =INFO
messageLevelDelphes=INFO
messageLevelOut    =INFO

## Define either pythia configuration file to generate events
pythiaConfFile="Generation/data/Pythia_ttbar.cmd"
if args.inputfile != '':
    pythiaConfFile = args.inputfile

## or pythia configuration file to read in LHE file & generate events
#pythiaConfFile="Generation/data/Pythia_LHEinput.cmd"

## Define Delphes card
delphesCard="Sim/SimDelphesInterface/data/delphes_card_CMS_ClassifyParticles_PropagatedGenJets_PU140.tcl"
if delphes_args.delphescard != None:
    delphesCard = delphes_args.delphescard


## Define Delphes input HepMC and optionaly (non-standard) ROOT output
##  - if ROOT file not defined --> data written-out to Gaudi data store (Ouputs)
# delphesRootOutFile="delphesOutput.root"
delphesRootOutFile=""

## This map defines the names of the output collections. The key of the top level dict corresponds to the output tool name
# The second level key - value corresponds to output-type - collection-name. NOTE: Do only change the values, not the keys.
out_names = {
    "muons": {"particles": "genMuons"},
    # Electron output tool
    "electrons": {"particles": "genElectrons", "mcAssociations": "electronsToMC", "isolationTags": "electronITags"},
    # Photons output tool
    "photons": {"particles": "genPhotons", "mcAssociations": "photonsToMC", "isolationTags": "photonITags"},
    # GenJets output tool
    "nonPropagatedGenJets": {"genJets": "nonPropagatedGenJets", "genJetsFlavorTagged": "nonPropagatedGenJetsFlavor"},
    "propagatedGenJets": {"genJets": "propagatedGenJets", "genJetsFlavorTagged": "propagatedGenJetsFlavor"},
    "nonPropagatedGenJetsPileUp": {"genJets": "nonPropagatedGenJetsPileUp", "genJetsFlavorTagged": "nonPropagatedGenJetsPileUpFlavor"},
    "propagatedGenJetsPileUp": {"genJets": "propagatedGenJetsPileUp", "genJetsFlavorTagged": "propagatedGenJetsPileUpFlavor"},
    # Missing transverse energy output tool
    "met": {"missingEt": "genMET"}
    }

## Data event model based on Podio
podioEvent=FCCDataSvc("EventDataSvc")

############################################################
#
# Expert: Configure individual modules (algorithms)
#
############################################################
# Define all output tools that convert the Delphes collections to FCC-EDM:

muonSaveTool = DelphesSaveChargedParticles("genMuons", delphesArrayName="GenMuonFilter/muons")
apply_paths(muonSaveTool, out_names["muons"])

eleSaveTool = DelphesSaveChargedParticles("genElectrons", delphesArrayName="GenElectronFilter/electrons")
apply_paths(eleSaveTool, out_names["electrons"])

photonsSaveTool = DelphesSaveNeutralParticles("genPhotons", delphesArrayName="GenPhotonFilter/photons")
apply_paths(photonsSaveTool, out_names["photons"])

nonPropagatedGenJetSaveTool = DelphesSaveGenJets("nonPropagatedGenJets", delphesArrayName="NonPropagatedGenJetFinder/jets")
apply_paths(nonPropagatedGenJetSaveTool, out_names["nonPropagatedGenJets"])

propagatedGenJetSaveTool = DelphesSaveGenJets("propagatedGenJets", delphesArrayName="PropagatedGenJetFinder/jets")
apply_paths(propagatedGenJetSaveTool, out_names["propagatedGenJets"])

nonPropagatedGenJetSaveToolPileUp = DelphesSaveGenJets("nonPropagatedGenJetsPileUp", delphesArrayName="NonPropagatedGenJetFinderPileUp/jets")
apply_paths(nonPropagatedGenJetSaveToolPileUp, out_names["nonPropagatedGenJetsPileUp"])

propagatedGenJetSaveToolPileUp = DelphesSaveGenJets("propagatedGenJetsPileUp", delphesArrayName="PropagatedGenJetFinderPileUp/jets")
apply_paths(propagatedGenJetSaveToolPileUp, out_names["propagatedGenJetsPileUp"])

metSaveTool = DelphesSaveMet("genMET", delphesMETArrayName="GenMissingET/momentum", delphesSHTArrayName="GenScalarHT/energy")
apply_paths(metSaveTool, out_names["met"])

#### Pythia generator
from Configurables import PythiaInterface
from Configurables import PoissonPileUp
from Configurables import HepMCFullMerge
from Configurables import GaussSmearVertex
from FCCPileupScenarios import FCCPhase1PileupConf as pileupconf

smeartool = GaussSmearVertex(
    xVertexSigma=pileupconf['xVertexSigma'],
    yVertexSigma=pileupconf['yVertexSigma'],
    zVertexSigma=pileupconf['zVertexSigma'],
    tVertexSigma=pileupconf['tVertexSigma'],
)

pythia8gentool = PythiaInterface(Filename=pythiaConfFile, OutputLevel=messageLevelPythia)
mergetool = HepMCFullMerge()
## Write the HepMC::GenEvent to the data service
from Configurables import GenAlg
pythia8gen = GenAlg("Pythia8", SignalProvider=pythia8gentool)
pythia8gen.hepmc.Path = "hepmc"

## Delphes simulator -> define objects to be written out
from Configurables import DelphesSimulation
delphessim = DelphesSimulation(DelphesCard=delphesCard,
                               ROOTOutputFile=delphesRootOutFile,
                               ApplyGenFilter=True,
                               OutputLevel=messageLevelDelphes,
                               outputs=["DelphesSaveChargedParticles/genMuons",
                                        "DelphesSaveChargedParticles/genElectrons",
                                        "DelphesSaveNeutralParticles/genPhotons",
                                        "DelphesSaveGenJets/nonPropagatedGenJets",
                                        "DelphesSaveGenJets/nonPropagatedGenJetsPileUp",
                                        "DelphesSaveGenJets/propagatedGenJets",
                                        "DelphesSaveGenJets/propagatedGenJetsPileUp",
                                        "DelphesSaveMet/genMET"])
delphessim.hepmc.Path                = "hepmc"
delphessim.genParticles.Path        = "skimmedGenParticles"
delphessim.mcEventWeights.Path      = "mcEventWeights"

### Reads an HepMC::GenEvent from the data service and writes a collection of EDM Particles
from Configurables import HepMCToEDMConverter
hepmc_converter = HepMCToEDMConverter("Converter")
hepmc_converter.hepmc.Path="hepmc"
hepmc_converter.genparticles.Path="genParticles"
hepmc_converter.genvertices.Path="genVertices"

## FCC event-data model output -> define objects to be written out
from Configurables import PodioOutput

out = PodioOutput("out",OutputLevel=messageLevelOut)
out.filename       = "FCCDelphesOutput.root"
if args.outputfile != '':
    out.filename = args.outputfile

#out.outputCommands = ["drop *",
#                      "keep genParticles",
#                      "keep genVertices",
#                      "keep genJets",
#                      "keep genJetsToMC"]
out.outputCommands = ["keep *", "drop genParticles", "drop genVertices"]

############################################################
#
# Run modules
#
############################################################
# Run Pythia + Delphes
ApplicationMgr( TopAlg = [ pythia8gen, hepmc_converter, delphessim, out ],
                EvtSel = 'NONE',
                EvtMax = nEvents,
                ExtSvc = [podioEvent])

ApplicationMgr.EvtMax=10

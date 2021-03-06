
### \file
### \ingroup BasicExamples
### | **input (alg)**                                      | other algorithms                   |                       |                                       | **output (alg)**                                |
### | ---------------------------------------------------- | ---------------------------------- | --------------------- | ------------------------------------- | ----------------------------------------------- |
### | generate Pythia events and save them to HepMC file   | convert `HepMC::GenEvent` to EDM   | filter MC Particles   | use sample jet clustering algorithm   | write the EDM output to ROOT file using PODIO   |

from Gaudi.Configuration import *
from FCCPileupScenarios import FCCPhase1PileupConf as pileupconf

### Example of pythia configuration file to generate events
pythiafile="Generation/data/Pythia_standard.cmd"
# Example of pythia configuration file to read LH event file
#pythiafile="options/Pythia_LHEinput.cmd"

from Configurables import FCCDataSvc
#### Data service
podioevent = FCCDataSvc("EventDataSvc")

## N-events
from FWCore.joboptions import parse_standard_job_options
args = parse_standard_job_options()
nEvents=1
if args.nevents is not None:
    nEvents = args.nevents

from Configurables import PoissonPileUp

pileuptool = PoissonPileUp(numPileUpEvents=pileupconf['numPileUpEvents'], Filename="Generation/data/Pythia_minbias_pp_100TeV.cmd")

from Configurables import PythiaInterface
### PYTHIA algorithm
pythia8gen = PythiaInterface("Pythia8Interface", Filename="Generation/data/Pythia_minbias_pp_100TeV.cmd")
pythia8gen.PileUpTool = pileuptool
pythia8gen.DataOutputs.hepmc.Path = "hepmcevent"


from Configurables import HepMCConverter
### Reads an HepMC::GenEvent from the data service and writes a collection of EDM Particles
hepmc_converter = HepMCConverter("Converter")
hepmc_converter.DataInputs.hepmc.Path="hepmcevent"
hepmc_converter.DataOutputs.genparticles.Path="all_genparticles"
hepmc_converter.DataOutputs.genvertices.Path="all_genvertices"

from Configurables import GenParticleFilter
### Filters generated particles
genfilter = GenParticleFilter("StableParticles")
genfilter.DataInputs.genparticles.Path = "all_genparticles"
genfilter.DataOutputs.genparticles.Path = "genparticles"

from Configurables import JetClustering_fcc__MCParticleCollection_fcc__GenJetCollection_ as JetClustering
genjet_clustering = JetClustering("GenJetClustering", verbose = False)
genjet_clustering.DataInputs.particles.Path='genparticles'
genjet_clustering.DataOutputs.jets.Path='genjets'

from Configurables import PodioOutput
### PODIO algorithm
out = PodioOutput("out",OutputLevel=DEBUG)
out.outputCommands = ["keep *"]
out.filename       = "FCCDelphesOutput.root"
if args.outputfile != '':
    out.filename = args.outputfile

from Configurables import ApplicationMgr
ApplicationMgr( TopAlg=[ pythia8gen, hepmc_converter, genfilter, genjet_clustering, out ],
                EvtSel='NONE',
                EvtMax=nEvents,
                ExtSvc=[podioevent]
)



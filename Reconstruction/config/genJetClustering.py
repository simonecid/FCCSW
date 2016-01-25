from Gaudi.Configuration import *
from Configurables import ApplicationMgr, HepMCReader, HepMCDumper, HepMCJetClustering
from Configurables import HepMCHistograms, JetHistograms

reader = HepMCReader("Reader", Filename="pythia.dat")
reader.DataOutputs.hepmc.Path = "hepmc"

dumper = HepMCDumper("Dumper")
dumper.DataInputs.hepmc.Path="hepmc"

genHisto = HepMCHistograms("GenHistograms")
genHisto.DataInputs.hepmc.Path="hepmc"

jets = HepMCJetClustering("ktCluster")
jets.JetAlgorithm = "kt"
jets.RecominbationScheme = "E"
jets.ConeRadius = 0.7
jets.PtMin = 1
jets.DataInputs.hepmc.Path="hepmc"
jets.DataOutputs.jets.Path="ktJets"

jetHisto = JetHistograms("JetHistograms")
jetHisto.DataInputs.jets.Path="ktJets"

THistSvc().Output = ["rec DATAFILE='GenHistograms.root' TYP='ROOT' OPT='RECREATE'"]
THistSvc().PrintAll=True
THistSvc().AutoSave=True
THistSvc().AutoFlush=True
THistSvc().OutputLevel=VERBOSE

ApplicationMgr(EvtSel='NONE',
               EvtMax=1,
               TopAlg=[reader,dumper,genHisto,jets,jetHisto])

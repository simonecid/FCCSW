#######################################
# Order of execution of various modules
#######################################

set ExecutionPath {

  GenElectronFilter
  GenMuonFilter
  GenPhotonFilter

  NeutrinoFilter
  GenJetFinder
  GenMissingET
  GenScalarHT
    
}

#################
# Generator-level electron filter
#################

module PdgCodeFilter GenElectronFilter {
  set InputArray Delphes/stableParticles
  set OutputArray electrons
  set Invert true
  add PdgCode {11}
  add PdgCode {-11}
}

#################
# Generator-level Muon filter
#################

module PdgCodeFilter GenMuonFilter {
  set InputArray Delphes/stableParticles
  set OutputArray muons
  set Invert true
  add PdgCode {13}
  add PdgCode {-13}
}

#################
# Generator-level photon filter
#################

module PdgCodeFilter GenPhotonFilter {
  set InputArray Delphes/stableParticles
  set OutputArray photons
  set Invert true
  add PdgCode {22}
  add PdgCode {-22}
}

#####################
# Neutrino Filter
#####################

module PdgCodeFilter NeutrinoFilter {

  set InputArray Delphes/stableParticles
  set OutputArray filteredParticles

  set PTMin 0.0

  add PdgCode {12}
  add PdgCode {14}
  add PdgCode {16}
  add PdgCode {-12}
  add PdgCode {-14}
  add PdgCode {-16}

}


#####################
# MC truth jet finder
#####################

module FastJetFinder GenJetFinder {
  set InputArray NeutrinoFilter/filteredParticles

  set OutputArray jets

  # algorithm: 1 CDFJetClu, 2 MidPoint, 3 SIScone, 4 kt, 5 Cambridge/Aachen, 6 antikt
  set JetAlgorithm 6
  set ParameterR 0.4

  set JetPTMin 3.0
}

#########################
# Gen Missing ET merger
########################

module Merger GenMissingET {
# add InputArray InputArray
  add InputArray NeutrinoFilter/filteredParticles
  set MomentumOutputArray momentum
}

##################
# Gen-level Scalar HT merger
##################

module Merger GenScalarHT {
# add InputArray InputArray
  add InputArray GenJetFinder/jets
  add InputArray GenElectronFilter/electrons
  add InputArray GenPhotonFilter/photons
  add InputArray GenMuonFilter/muons
  set EnergyOutputArray energy
}

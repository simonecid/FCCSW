#######################################
# Order of execution of various modules
#######################################

set ExecutionPath {

  PropagateToECAL

  GenElectronFilter
  GenMuonFilter
  GenPhotonFilter
  NonPropagatedNeutrinoFilter
  NonPropagatedGenJetFinder
  GenMissingET
  GenScalarHT
  PropagatedNeutrinoFilter
  PropagatedGenJetFinder
    
}

#########################################
# Propagate particles in cylinder to ECAL
#########################################

module ParticlePropagator PropagateToECAL {
  set InputArray Delphes/stableParticles

  set OutputArray stableParticles
  set ChargedHadronOutputArray chargedHadrons
  set ElectronOutputArray electrons
  set MuonOutputArray muons

  # radius of the magnetic field coverage, in m
  set Radius 1.29
  # half-length of the magnetic field coverage, in m
  set HalfLength 3.00

  # magnetic field
  set Bz 3.8
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

module PdgCodeFilter NonPropagatedNeutrinoFilter {

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

module FastJetFinder NonPropagatedGenJetFinder {
  set InputArray NonPropagatedNeutrinoFilter/filteredParticles

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
  add InputArray NonPropagatedNeutrinoFilter/filteredParticles
  set MomentumOutputArray momentum
}

##################
# Gen-level Scalar HT merger
##################

module Merger GenScalarHT {
# add InputArray InputArray
  add InputArray NonPropagatedGenJetFinder/jets
  add InputArray GenElectronFilter/electrons
  add InputArray GenPhotonFilter/photons
  add InputArray GenMuonFilter/muons
  set EnergyOutputArray energy
}

#####################
# Neutrino Filter
#####################

module PdgCodeFilter PropagatedNeutrinoFilter {

  set InputArray PropagateToECAL/stableParticles
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

module FastJetFinder PropagatedGenJetFinder {
  set InputArray PropagatedNeutrinoFilter/filteredParticles

  set OutputArray jets

  # algorithm: 1 CDFJetClu, 2 MidPoint, 3 SIScone, 4 kt, 5 Cambridge/Aachen, 6 antikt
  set JetAlgorithm 6
  set ParameterR 0.4

  set JetPTMin 3.0
}
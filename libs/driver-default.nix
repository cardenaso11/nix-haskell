# A default a driver states for itself on a mirrored common option.
# Priority 1450 sits between the mirror seeds (1400) and the declaration
# defaults (1500):
# - A top-level definition seeds the mirror at 1400 and beats the driver
#   default.
# - The driver default beats the bare declaration default at 1500.
# mkDefault (1000) cannot express this. It would beat the seeds and cut the
# mirrors off from the top-level values.
#
# Example:
#
#   mkDriverDefault = import ./driver-default.nix { inherit lib; };
#
#   { haskell-nix.compiler.name = mkDriverDefault "ghc914"; }
#   => config."haskell-nix".compiler.name == "ghc914", the driver's own choice,
#      since the project named no compiler and the declaration default (1500)
#      loses to it
#
#   { compiler.name = "ghc912";
#     haskell-nix.compiler.name = mkDriverDefault "ghc914"; }
#   => config."haskell-nix".compiler.name == "ghc912": the project's value is
#      seeded into the mirror at 1400, which beats 1450
{ lib }:

lib.mkOverride 1450

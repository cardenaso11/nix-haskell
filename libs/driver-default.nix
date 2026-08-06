# A default for a common option that individual drivers may override:
# between the mirror seeds (1400) and the declaration defaults (1500), so a
# top-level definition reaches the mirrors, but the bare default does not
# override a driver's choice. mkDefault (1000) cannot express this: it would
# beat the seeds, cutting the mirrors off from the top-level values.
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

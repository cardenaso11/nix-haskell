# The base Haskell package set for a resolved `compiler` entry (see
# ../compiler.nix), from a nixpkgs package set: a name selects
# `haskell.packages.<name>`; a package overrides the `ghc` of the set
# matching its derived name, falling back to the default `haskellPackages`
# when no set matches.
{ lib, pkgs, compiler }:

with lib;

if compiler.package != null
then (pkgs.haskell.packages.${compiler.name} or pkgs.haskellPackages)
       .override { ghc = compiler.package; }
else pkgs.haskell.packages.${compiler.name}
  or (throw ("nix-haskell (nixpkgs driver): haskell.packages for ${pkgs.stdenv.hostPlatform.system}"
    + " has no \"${compiler.name}\""
    + " (available: ${concatStringsSep ", " (filter (hasPrefix "ghc") (attrNames pkgs.haskell.packages))});"
    + " set nixpkgs.compiler or nixpkgs.haskellPackages"))

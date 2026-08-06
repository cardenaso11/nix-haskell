# The base Haskell package set for a resolved compiler entry, out of a nixpkgs
# package set. A named compiler selects `haskell.packages.<name>`. A compiler
# package replaces the `ghc` of the set that matches it most closely: the set
# of its own major.minor.patch, then the set it names, then whatever the
# package set offers by default. The closest set matters because everything
# outside the project is built from it, so its bounds and its boot libraries
# should be the ones the compiler was built with.
#
# Example:
#
#   import ./haskell-packages.nix { inherit lib pkgs; compiler = <entry>; }
#   => <pkgs.haskell.packages.ghc9124 with the bindist as its ghc>, for an entry
#      whose package is a 9.12.4 bindist named ghc912
#   => pkgs.haskell.packages.ghc912, for an entry with a name and no package
#   => a throw naming the ghc* sets this nixpkgs does have, for a name it has
#      none of
{ lib, pkgs, compiler }:

with lib;

if compiler.annotated != null
then
  ( pkgs.haskell.packages.${compiler.stockName}
    or pkgs.haskell.packages.${compiler.name}
    or pkgs.haskellPackages
  ).override { ghc = compiler.annotated; }
else pkgs.haskell.packages.${compiler.name}
  or (throw ("nix-haskell (nixpkgs driver): haskell.packages for"
    + " ${pkgs.stdenv.hostPlatform.system} has no \"${compiler.name}\""
    + " (available: ${concatStringsSep ", " (filter (hasPrefix "ghc") (attrNames pkgs.haskell.packages))});"
    + " set nixpkgs.compiler.name or nixpkgs.haskellPackages"))

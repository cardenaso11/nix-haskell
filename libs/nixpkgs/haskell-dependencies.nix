# The Haskell packages that a package builds against, from the set's record
# of its cabal dependencies. Setup dependencies are not included. They build
# with the native compiler and use a database of their own.
#
# Example:
#
#   import ./haskell-dependencies.nix { inherit lib; } hp.reflex-todomvc
#   => [ <derivation reflex-0.9.3.4> <derivation text-2.1.2> ]
{ lib }:

package:

let isRunDependency = name:
      name == "buildDepends"
      || (lib.hasSuffix "HaskellDepends" name && name != "setupHaskellDepends");

    runDependencies = lib.filterAttrs (name: _: isRunDependency name) package.getCabalDeps;

    stated = lib.concatLists (lib.attrValues runDependencies);

in lib.filter (dependency: dependency != null) stated

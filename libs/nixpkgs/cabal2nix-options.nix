# The options cabal2nix generates a package expression with. Cabal flags of
# generated packages go through cabal2nix, so it computes the dependency
# graph under the right flag assignment. Disabled tests and documentation
# become part of the generated expression. cabal2nix keeps test
# dependencies as required arguments even with --no-check, so a test
# dependency absent from the package set still needs an explicit null
# override.
#
# `tweaks` is the package's entry in the platform-merged `packages` map,
# `{}` when it has none. `name` is unused here. It is part of the call so
# a replacement can vary the options per package.
#
# Example:
#
#   cabal2nix-options = import ./cabal2nix-options.nix { inherit lib; };
#
#   cabal2nix-options {
#     name = "reflex-dom";
#     external = true;
#     tweaks = { flags = { use-warp = true; webkit2gtk = false; }; };
#     extra-package-defaults = { check = false; haddock = false; jailbreak = false; };
#   }
#   => "--flag=use-warp --flag=-webkit2gtk --no-check --no-haddock"
#
#   cabal2nix-options {
#     name = "hello";
#     external = false;
#     tweaks = {};
#     extra-package-defaults = { check = false; haddock = false; jailbreak = false; };
#   }
#   => ""
{ lib }:

{ name, external, tweaks, extra-package-defaults }:

let disabled = field: tweaks.${field} or null == false;

    unset = field: tweaks.${field} or null == null;

    noCheck = disabled "doCheck"
      || (external && !extra-package-defaults.check && unset "doCheck");

    noHaddock = disabled "doHaddock"
      || (external && !extra-package-defaults.haddock && unset "doHaddock");

    flagOptions = lib.mapAttrsToList
      (f: enabled: "--flag=${lib.optionalString (!enabled) "-"}${f}")
      (tweaks.flags or {});

in lib.concatStringsSep " " (
     flagOptions
     ++ lib.optional noCheck "--no-check"
     ++ lib.optional noHaddock "--no-haddock")

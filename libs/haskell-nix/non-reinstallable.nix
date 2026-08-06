# A haskell.nix module adding the boot packages a compiler names to the ones a
# project takes from the compiler's database rather than building. A package the
# compiler was configured against, but which is in neither list the driver
# copies out of it, is left unresolved for everything downstream of it.
#
# The list replaces rather than extends when it is defined, so haskell.nix's own
# definition is read and appended to instead of being restated: what it contains
# depends on the compiler's version and on the target, and carries the packages
# a cross target's Template Haskell needs.
#
# The module goes into every project the driver builds, including the ones for
# the build platform, and decides per evaluation whether it applies: the
# compiler of the platform being built is the one that names the packages.
#
# Example:
#
#   import ./non-reinstallable.nix {
#     inherit lib compilers;
#     haskell-nix-src = config.inputs."haskell-nix";
#   }
#   => <a haskell.nix module>
{ lib, compilers, haskell-nix-src }:

{ pkgs, ... }@args:

let compiler = compilers.resolve (compilers.targetKey pkgs.stdenv.hostPlatform);

    upstream = import "${haskell-nix-src}/modules/install-plan/non-reinstallable.nix" args;

in {

  # `mkIf` rather than a conditional module body: `pkgs` reaches a module
  # through `_module.args`, so deciding the module's own attributes on it is a
  # cycle.
  config = lib.mkIf (compiler.extraNonReinstallablePkgs != []) {
    nonReinstallablePkgs =
      upstream.nonReinstallablePkgs ++ compiler.extraNonReinstallablePkgs;
  };

}

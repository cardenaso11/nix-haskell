# A haskell.nix module adding the boot packages a compiler names to the
# ones a project takes from the compiler's database rather than building. A
# package the compiler was configured against, but absent from both lists
# the driver copies out of it, stays unresolved for everything downstream
# of it.
#
# A definition of the list replaces it rather than extends it. This module
# therefore reads haskell.nix's own definition and appends to it instead of
# restating it. That list depends on the compiler's version and on the
# target, and carries the packages a cross target's Template Haskell needs.
#
# The module goes into every project the driver builds, including the ones
# for the build platform, and decides per evaluation whether it applies.
# The compiler of the platform being built names the packages.
#
# Example:
#
#   import ./non-reinstallable.nix {
#     inherit lib compilers;
#     haskell-nix-src = config.inputs."haskell-nix";
#   }
#   => a haskell.nix module which, in the project whose compiler names
#      `system-cxx-std-lib`, evaluates to
#
#        config.nonReinstallablePkgs = [
#          "rts" "base" "ghc-prim" "integer-gmp" "integer-simple"  # haskell.nix's
#          "ghc-bignum" "ghc-internal" "ghci" ...                  # own list
#          "system-cxx-std-lib"                                    # the compiler's
#        ];
#
#      and in a project whose compiler names none, to nothing, leaving
#      haskell.nix's list as it was
{ lib, compilers, haskell-nix-src }:

{ pkgs, ... }@args:

let compiler = compilers.resolve (compilers.targetKey pkgs.stdenv.hostPlatform);

    upstream = import "${haskell-nix-src}/modules/install-plan/non-reinstallable.nix" args;

in {

  # This module must use mkIf, not a conditional body. `pkgs` reaches a
  # module through `_module.args`, so a module body that depends on `pkgs`
  # is a cycle.
  config = lib.mkIf (compiler.extraNonReinstallablePkgs != []) {
    nonReinstallablePkgs =
      upstream.nonReinstallablePkgs ++ compiler.extraNonReinstallablePkgs;
  };

}

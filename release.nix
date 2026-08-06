# Everything worth building before releasing: the repo's own checks, and the
# reflex-todomvc example across every driver, compiler and cross target it is
# meant to work for, built both as the drivers build it and as a person would
# inside the project's shell.
#
#   nix-build release.nix -A all
#   nix-build release.nix -A checks
#   nix-build release.nix -A reflex-todomvc.build.haskell-nix.ghc912.wasi32
#
# `all` is a directory of symlinks to every other attribute, so one build
# realises the lot and names what it realised.
{ system ? builtins.currentSystem, inputs ? {} }:

let pkgs = (import ./default.nix { inherit system inputs; } {}).pkgs;

    inherit (pkgs) lib;

    # Every derivation in a tree of attribute sets, named by its path, which is
    # also where it lands in `all`.
    entries = prefix: value:
      if lib.isDerivation value
      then [ { name = prefix; path = value; } ]
      else lib.concatLists (lib.mapAttrsToList
        (name: entry: entries (if prefix == "" then name else "${prefix}/${name}") entry)
        value);

    released = {

      checks = import ./tests { inherit system inputs; };

      reflex-todomvc = import ./examples/reflex-todomvc/release.nix {
        inherit system inputs;
      };

    };

in released // {

  all = pkgs.linkFarm "nix-haskell-release" (entries "" released);

}

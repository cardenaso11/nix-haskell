{ lib, ... }:

with lib;

{

  options = {

    inputs = mkOption {
      type = types.lazyAttrsOf types.raw;
      apply = mapAttrs (_: import ../libs/thunk.nix);
      default = {};
      description = ''
        Sources of dependencies, keyed the way flake inputs are. An entry
        accepts whatever a flake input can be: a flake input, a store path, a
        checkout, or a packed thunk. Entries beyond the ones in `pins/` may be
        added freely.
      '';
    };

  };

  config = {

    inputs = mapAttrs (_: mkOptionDefault) (import ../libs/thunks.nix ../pins);

  };

}

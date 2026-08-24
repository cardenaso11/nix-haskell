{ lib, ... }:

with lib;

{

  options = {

    inputs = mkOption {
      type = types.attrsOf types.raw;
      apply = mapAttrs (_: import ../libs/thunk.nix);
      default = {};
      description = ''
        Sources of dependencies, keyed the way flake inputs are. An entry
        accepts whatever a flake input can be: a flake input, a store path,
        a checkout, or a packed thunk. Add entries beyond the ones in
        `pins/` freely.
      '';
    };

  };

  config = {

    inputs = mapAttrs (_: mkOptionDefault) (import ../libs/thunks.nix ../pins);

  };

}

{ config, lib, ... }:

with lib;

let thunkSource = import ../libs/thunk.nix;

in {

  options = {

    thunks = mapAttrs
      ( _: value: mkOption {
          type = types.path;
          default = thunkSource value;
      }) config.pins;

  };

}

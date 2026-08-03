# The common options mirrored under a driver's namespace: their
# declarations (hidden from the manual), seeds from the top-level values at
# option-default priority, and the common module's own config. Driver
# definitions override the seeds, so a common option can be changed for one
# driver only. The declarations are evaluated against the mirror itself
# (`cfg`), so defaults like name-from-src follow the driver's values.
#
# Example:
#
#   config.nixpkgs.packages.reflex-dom.flags.webkit2gtk = false;
#   => config.nixpkgs.<common option> == config.<common option>,
#      except for that flag
{ lib, pkgs, topConfig, cfg }:

with lib;

let commonModule = import ../modules/common.nix { inherit lib pkgs; config = cfg; };

    isSettable = option':
      let defaults = {
            internal = false;
            readOnly = false;
          };
          option = defaults // option';
      in all id
        [ (isOption option)
          (!option.internal)
          (!option.readOnly)
        ];

in {

  options = mapAttrs (_: option: option // { visible = false; }) commonModule.options;

  # Submodule-typed options are seeded per field, so a driver definition of
  # one field leaves the others at the common values. Seeds sit between
  # mkDefault (1000) and option defaults (1500): weaker than any definition,
  # stronger than the mirror's own declaration defaults. mkOptionDefault
  # cannot be used, since declaration defaults materialize at its priority
  # and equal-priority definitions conflict.
  seeds =
    let seed = mkOverride 1400;

        settableOptions = filterAttrs (_: isSettable) commonModule.options;

        seedValue = option: value:
          let type = option.type;
              isSubmodule = type.name == "submodule";
              isAttrsOfSubmodule =
                   (type.name == "attrsOf" || type.name == "lazyAttrsOf")
                && (type.nestedTypes.elemType.name or "") == "submodule";
          in  if isSubmodule
                then mapAttrs (_: seed) value
              else if isAttrsOfSubmodule
                then mapAttrs (_: fields: mapAttrs (_: seed) fields) value
              else seed value;

    in mapAttrs (name: option: seedValue option topConfig.${name}) settableOptions;

  inherit (commonModule) config;

}

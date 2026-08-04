# The common options mirrored under a driver's namespace: their
# declarations (hidden from the manual), seeds from the top-level values the
# user actually defined, and the common module's own config. Driver
# definitions override the seeds, so a common option can be changed for one
# driver only. Options left entirely to their defaults are not seeded: they
# fall to the mirror's own declaration defaults, which are evaluated against
# the mirror itself (`cfg`), so defaults like name-from-src follow the
# driver's values.
#
# Example:
#
#   config.nixpkgs.packages.reflex-dom.flags.webkit2gtk = false;
#   => config.nixpkgs.<common option> == config.<common option>,
#      except for that flag
{ lib, pkgs, topConfig, topOptions, cfg }:

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
  #
  # Only options with top-level definitions are seeded, so a driver default
  # (mkDriverDefault, 1450) yields to a value the user chose but not to the
  # bare common defaults. Declaration defaults do not count: the module
  # system injects them as definitions at mkOptionDefault priority (1500),
  # so a definition is one that beats that. Reading any mirror option forces
  # the definition priorities of every settable common option, so top-level
  # common options must not be gated on driver config.
  seeds =
    let seed = mkOverride 1400;

        settableOptions = filterAttrs (_: isSettable) commonModule.options;

        declarationDefaultPrio = (mkOptionDefault null).priority;

        definedOptions =
          filterAttrs
            (name: _: topOptions.${name}.highestPrio < declarationDefaultPrio)
            settableOptions;

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

    in mapAttrs (name: option: seedValue option topConfig.${name}) definedOptions;

  inherit (commonModule) config;

  # See driver-default.nix.
  mkDriverDefault = import ./driver-default.nix { inherit lib; };

}

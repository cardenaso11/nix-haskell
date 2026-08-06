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
#   import ./driver-common.nix {
#     inherit lib pkgs cfg;
#     topConfig = config;    # a project defining packages.reflex-dom.flags.webkit2gtk
#     topOptions = options;
#   }
#   => { options = <every common option, hidden from the manual>;
#        seeds = {
#          packages.reflex-dom.flags = {          # the whole field, since
#            _type = "override";                  # `flags` is not a submodule
#            priority = 1400;                     # to descend into
#            content = { webkit2gtk = false; };
#          };
#          src = ...;                             # the project's other
#          system = ...;                          # definitions, seeded the
#          shell = ...;                           # same way
#        };
#        config = <the common module's own config>;
#        mkDriverDefault = <a definition at priority 1450>;
#      }
#
#   `packages.reflex-dom.patches` gets no seed, nor does any other field the
#   project left alone, so a driver default still reaches it. A driver's own
#   `nixpkgs.packages.reflex-dom.flags` beats the seed, which is how a common
#   option is changed for one driver only.
{ lib, pkgs, topConfig, topOptions, cfg }:

with lib;

let # `topConfig` as well as the mirror: an option whose value is settled once for
    # the project, rather than per driver, is read from there even when the
    # mirror is what carries it.
    commonModule = import ../modules/common.nix {
      inherit lib pkgs topConfig;
      config = cfg;
    };

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

  # Seeds sit between mkDefault (1000) and option defaults (1500): weaker
  # than any definition, stronger than the mirror's own declaration defaults.
  # mkOptionDefault cannot be used, since declaration defaults materialize at
  # its priority and equal-priority definitions conflict.
  #
  # Only what the project defined is seeded, down to the field: a seed is
  # placed on a path exactly when some top-level definition mentions it. So a
  # driver default (mkDriverDefault, 1450) still applies to every field the
  # project left alone, however deeply nested, and yields to any field it did
  # set. Seeding the whole of a submodule-typed option instead would defeat
  # driver defaults on all of its fields as soon as one of them was defined.
  # Declaration defaults do not count as definitions: the module system
  # injects them at mkOptionDefault priority (1500), so a definition is one
  # that beats that.
  #
  # Descent follows the declared sub-options rather than the values, so a
  # seed only ever lands where an option exists to receive it, and read-only
  # sub-options are left out (a read-only option set twice is an error).
  # Reading any mirror option forces the definition priorities of every
  # settable common option, so top-level common options must not be gated on
  # driver config.
  seeds =
    let seed = mkOverride 1400;

        settableOptions = filterAttrs (_: isSettable) commonModule.options;

        declarationDefaultPrio = (mkOptionDefault null).priority;

        definedOptions =
          filterAttrs
            (name: _: topOptions.${name}.highestPrio < declarationDefaultPrio)
            settableOptions;

        # A submodule's own settable options, which are what a definition of
        # it can name.
        subOptions = type:
          filterAttrs (name: option: name != "_module" && isSettable option)
            (type.getSubOptions []);

        # The definitions that can carry a path below them. A derivation is an
        # attrset too, and is a value rather than a path.
        pathDefs = defs: filter (def: isAttrs def && ! isDerivation def) defs;

        namedIn = defs: name: any (def: def ? ${name}) (pathDefs defs);

        under = defs: name: catAttrs name (pathDefs defs);

        seedOption = option: defs: value:
          let type = option.type;
              elemType = type.nestedTypes.elemType or null;
              isSubmodule = type.name == "submodule";
              isAttrsOfSubmodule =
                   (type.name == "attrsOf" || type.name == "lazyAttrsOf")
                && (elemType.name or "") == "submodule";
          in  if isSubmodule
                then seedFields (subOptions type) defs value
              else if isAttrsOfSubmodule
                then
                  let keys = filter (namedIn defs) (attrNames value);
                  in genAttrs keys
                       (key: seedFields (subOptions elemType) (under defs key) value.${key})
              else seed value;

        seedFields = fields: defs: value:
          mapAttrs
            (name: option: seedOption option (under defs name) value.${name})
            (filterAttrs (name: _: namedIn defs name) fields);

    in mapAttrs
         (name: option: seedOption option topOptions.${name}.definitions topConfig.${name})
         definedOptions;

  inherit (commonModule) config;

  # A default a driver states for itself, weaker than the seeds above, so it
  # applies only where the project said nothing.
  mkDriverDefault = import ./driver-default.nix { inherit lib; };

}

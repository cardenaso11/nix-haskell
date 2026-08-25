{ config, lib, ... }:

let cfg = config.optimizations;

    # One row per GHC flag: the option's name, the flag it emits (`-f<name>`
    # when the row states none), and the option's description. The option
    # and the emitted flag come from the same row, so an option cannot fall
    # out of the flag list.
    rows = [
      { name = "O2";
        flag = "-O2";
        description = ''
          Enable -O2: GHC applies every non-dangerous optimisation, at the
          cost of longer compile times.
        '';
      }
      { name = "expose-all-unfoldings";
        description = ''
          Enable -fexpose-all-unfoldings: write every function's unfolding
          into the interface file, even large or recursive ones, so other
          modules can inline and specialise them.
        '';
      }
      { name = "specialise";
        description = ''
          Enable -fspecialise: specialise each overloaded function for the
          types at which the defining module calls it.
        '';
      }
      { name = "specialise-aggressively";
        description = ''
          Enable -fspecialise-aggressively: specialise any overloaded function
          whose unfolding is available, not only INLINABLE ones. This may grow
          code size significantly.
        '';
      }
      { name = "late-specialise";
        description = ''
          Enable -flate-specialise: run one more specialisation pass late in
          the pipeline. It can catch opportunities that earlier specialisation
          and inlining exposed.
        '';
      }
      { name = "cross-module-specialise";
        description = ''
          Enable -fcross-module-specialise: specialise INLINABLE overloaded
          functions imported from other modules for the types at which they
          are called.
        '';
      }
    ];

    flagOption = row: lib.nameValuePair row.name (lib.mkOption {
      type = lib.types.bool;
      default = cfg.all;
      inherit (row) description;
    });

    rowFlags = lib.concatMap
      (row: lib.optional cfg.${row.name} (row.flag or "-f${row.name}"))
      rows;

    extraFlags = lib.attrNames (lib.filterAttrs (_: on: on) cfg.extra);

    flags = rowFlags ++ extraFlags;

in {
  options.optimizations = {
    all = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable every optimization flag in this module. Each flag can still
        be turned off on its own.
      '';
    };

    extra = lib.mkOption {
      type = lib.types.attrsOf lib.types.bool;
      default = {};
      example = { "-fllvm" = true; };
      description = ''
        Extra GHC flags by literal spelling:

        - a true value emits its key after the named rows, and GHC takes
          the last flag given
        - a false value emits nothing

        Entries are independent of `all`.
      '';
    };
  } // lib.listToAttrs (map flagOption rows);

  config = lib.mkIf (flags != []) {
    ghcOptions = flags;
  };
}

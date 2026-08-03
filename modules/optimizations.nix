{ config, lib, ... }:

let cfg = config.optimizations;

    flags = lib.concatLists [
      (lib.optional cfg.O2 "-O2")
      (lib.optional cfg.expose-all-unfoldings "-fexpose-all-unfoldings")
      (lib.optional cfg.specialise "-fspecialise")
      (lib.optional cfg.specialise-aggressively "-fspecialise-aggressively")
      (lib.optional cfg.late-specialise "-flate-specialise")
      (lib.optional cfg.cross-module-specialise "-fcross-module-specialise")
    ];

in {
  options.optimizations = {
    all = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable all optimization flags.";
    };

    O2 = lib.mkOption {
      type = lib.types.bool;
      default = cfg.all;
      description = "Enable -O2 optimization level.";
    };

    expose-all-unfoldings = lib.mkOption {
      type = lib.types.bool;
      default = cfg.all;
      description = "Enable -fexpose-all-unfoldings for cross-module optimization.";
    };

    specialise = lib.mkOption {
      type = lib.types.bool;
      default = cfg.all;
      description = "Enable -fspecialise.";
    };

    specialise-aggressively = lib.mkOption {
      type = lib.types.bool;
      default = cfg.all;
      description = "Enable -fspecialise-aggressively.";
    };

    late-specialise = lib.mkOption {
      type = lib.types.bool;
      default = cfg.all;
      description = "Enable -flate-specialise.";
    };

    cross-module-specialise = lib.mkOption {
      type = lib.types.bool;
      default = cfg.all;
      description = "Enable -fcross-module-specialise.";
    };
  };

  config = lib.mkIf (flags != []) {
    ghcOptions = flags;
  };
}

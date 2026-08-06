# The type of a driver's `translation` table: one entry per user-settable
# common option, stating how the driver honors it.
#
# The keys are the contract. The totality check (tests/) compares each
# driver's key set against the common options in both directions, so a common
# option a driver does not translate, or a stale entry for a removed option,
# fails evaluation. `shell` and `packages` sub-options get their own keys
# ("shell.tools", "packages.*.flags", ...) so new sub-options trip the check
# too.
#
# Example of a value of this type:
#
#   {
#     "compiler.name" = {
#       set = { compiler-nix-name = compiler.name; };
#       via = "project `compiler-nix-name`";
#     };
#     clean-src.via = "consumed by `src-cleaned`";   # set = null: no payload
#   }
{ lib }:

with lib;

types.attrsOf (types.submodule {
  options = {
    set = mkOption {
      type = types.nullOr types.raw;
      default = null;
      internal = true;
      description = ''
        Definition set merged into the driver's `options` submodule; null when
        the common option is consumed elsewhere (see `via`).
      '';
    };
    via = mkOption {
      type = types.str;
      internal = true;
      description = ''
        How the common option is honored by this driver.
      '';
    };
  };
})

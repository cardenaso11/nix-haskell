# Whether a listing or a manual shows the option: not hidden, not
# internal, not read-only. Flags absent from the declaration count as the
# permissive value. The argument must already be an option; callers test
# `lib.isOption` first.
#
# Hidden is not unsettable: a driver mirror hides its re-declared options
# and still seeds them.
#
# Example:
#
#   is-visible = import ./is-visible.nix { inherit lib; };
#
#   is-visible (lib.mkOption { type = lib.types.str; })
#   => true
#
#   is-visible ((lib.mkOption { type = lib.types.str; }) // { visible = false; })
#   => false
{ lib }:

let and = import ./and.nix { inherit lib; };

in option':

let defaults = {
      visible = true;
      internal = false;
      readOnly = false;
    };

    option = defaults // option';

in and [
  (option.visible != false)
  (!option.internal)
  (!option.readOnly)
]

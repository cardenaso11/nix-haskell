# Whether a definition may give the option a value: a real option that is
# neither internal nor read-only. Flags absent from the declaration count
# as the permissive value.
#
# Example:
#
#   is-settable = import ./is-settable.nix { inherit lib; };
#
#   is-settable (lib.mkOption { type = lib.types.str; })
#   => true
#
#   is-settable ((lib.mkOption { type = lib.types.str; }) // { readOnly = true; })
#   => false
#
#   is-settable { not = "an option"; }
#   => false
{ lib }:

let and = import ./and.nix { inherit lib; };

in option':

let defaults = {
      internal = false;
      readOnly = false;
    };

    option = defaults // option';

in and [
  (lib.isOption option)
  (!option.internal)
  (!option.readOnly)
]

# The conjunction of a list of booleans:
# - `true` when every element is `true`.
# - `true` for `[]`.
#
# Example:
#
#   and = import ./and.nix { inherit lib; };
#
#   and [ true true ]
#   => true
#
#   and [ true false ]
#   => false
#
#   and []
#   => true
{ lib }:

lib.all lib.id

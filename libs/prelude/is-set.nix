# Whether a project stated a value for an option field:
# - `null`, `[]` and `{}` are the empty defaults of nullable, list and
#   attrset fields, so they mean the field was left alone.
# - Everything else counts as stated, including `false`.
#
# Example:
#
#   is-set = import ./is-set.nix { inherit lib; };
#
#   is-set null
#   => false
#
#   is-set []
#   => false
#
#   is-set {}
#   => false
#
#   is-set [ "-O2" ]
#   => true
#
#   is-set false
#   => true
{ lib }:

let and = import ./and.nix { inherit lib; };

in value:

and [
  (value != null)
  (value != [])
  (value != {})
]

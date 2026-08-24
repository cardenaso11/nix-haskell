# One field of a bundle optimizer's settings, declared for the kind of layer it
# sits on. `inherits` names what a `null` falls through to: give it and the field
# is `nullOr` of its type, defaults to `null`, and its description gains a
# paragraph saying so; leave it out and the field carries its real type and the
# value every other layer falls back to.
#
# Naming what a `null` leaves the field to is not optional, since supplying that
# name is what makes the layer nullable at all. The two cannot drift apart.
#
# Example:
#
#   import ./bundle-optimizer-field.nix { inherit lib; } {
#     type = lib.types.enum [ "0" "1" "2" ];
#     default = "2";
#     description = "The `-O` level wasm-opt runs at.";
#     example = "0";
#   }
#   => <option, type enum [ "0" "1" "2" ], default "2", example "0",
#      description as given>
#
#   import ./bundle-optimizer-field.nix {
#     inherit lib;
#     inherits = "the layer beneath it";
#   } {
#     type = lib.types.enum [ "0" "1" "2" ];
#     default = "2";
#     description = "The `-O` level wasm-opt runs at.";
#   }
#   => <option, type nullOr (enum [ "0" "1" "2" ]), default null, no example,
#      description "The `-O` level wasm-opt runs at.
#
#                   `null` states nothing, leaving the field to the layer
#                   beneath it.">
{ lib, inherits ? null }:

let stated = inherits == null;

    # A leading blank line, so the sentence becomes its own paragraph rather
    # than running on from the description it is appended to.
    leftTo = lib.optionalString (! stated) ''

      `null` states nothing, leaving the field to ${inherits}.
    '';

in { type, default, description, example ? null }:
     lib.mkOption ({
       type = if stated then type else lib.types.nullOr type;
       default = if stated then default else null;
       description = description + leftTo;
     } // lib.optionalAttrs (example != null) { inherit example; })

# One field of a bundle optimizer's settings, declared for the kind of layer
# it sits on:
# - Without `inherits`, the field carries its real type and the value every
#   other layer falls back to.
# - With `inherits`, the field is nullable and defaults to `null`, and its
#   description gains a paragraph saying what `null` leaves it to.
#
# The one `inherits` argument both names the fall-through and switches the
# field to nullable, so the two cannot drift apart. Every other argument
# passes to `mkOption` as given.
#
# Example:
#
#   import ./field.nix { inherit lib; } {
#     type = lib.types.enum [ "0" "1" "2" ];
#     default = "2";
#     description = "The `-O` level wasm-opt runs at.";
#     example = "0";
#   }
#   => <option, type enum [ "0" "1" "2" ], default "2", example "0",
#      description as given>
#
#   import ./field.nix {
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
#                   `null` states nothing and leaves the field to the layer
#                   beneath it.">
{ lib, inherits ? null }:

let stated = inherits == null;

    # The leading blank line makes the appended sentence its own paragraph.
    leftTo = lib.optionalString (! stated) ''

      `null` states nothing and leaves the field to ${inherits}.
    '';

in args@{ type, default, description, ... }:
     lib.mkOption (args // {
       type = if stated then type else lib.types.nullOr type;
       default = if stated then default else null;
       description = description + leftTo;
     })

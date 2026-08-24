# The settings every bundle optimizer takes, keyed by the tool whose flags they
# are, so a caller declaring a whole layer of the tree names it once instead of
# naming each tool. `inherits` decides the kind of layer, and reaches both;
# `bundle-optimizer-field.nix` spells out what it does.
#
# Example:
#
#   import ./bundle-optimizer-options.nix { inherit lib; }
#   => { wasm-opt         = <the three fields of ./wasm-opt/options.nix>;
#        closure-compiler = <the four fields of ./closure-compiler/options.nix>;
#      }
#
#   import ./bundle-optimizer-options.nix {
#     inherit lib;
#     inherits = "the setting for this package whatever the target";
#   }
#   => the same two field sets, every field `nullOr` of its type and defaulting
#      to `null`, its description saying what `null` leaves it to
{ lib, inherits ? null }:

{

  wasm-opt = import ./wasm-opt/options.nix { inherit lib inherits; };

  closure-compiler = import ./closure-compiler/options.nix { inherit lib inherits; };

}

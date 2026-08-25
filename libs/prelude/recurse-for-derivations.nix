# A tree of derivations with every level marked for `nix-build`, which
# descends into an attribute set only where it is told it may.
#
# Example:
#
#   recurse-for-derivations = import ./recurse-for-derivations.nix { inherit lib; };
#
#   recurse-for-derivations { serverExe = { wasm = <drv>; }; }
#   => { serverExe = { wasm = <drv>; recurseForDerivations = true; };
#        recurseForDerivations = true;
#      }
#
#   recurse-for-derivations {}
#   => { recurseForDerivations = true; }
{ lib }:

let mark = attrs:
      let descend = value:
            if lib.isAttrs value && ! lib.isDerivation value
            then mark value
            else value;
      in lib.mapAttrs (_: descend) attrs
         // { recurseForDerivations = true; };

in mark

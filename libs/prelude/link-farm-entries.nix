# Every derivation in a tree, named by its path through that tree, in the
# shape `pkgs.linkFarm` takes. The `recurseForDerivations` markers guide
# `nix-build` and are not entries.
#
# Example:
#
#   link-farm-entries = import ./link-farm-entries.nix { inherit lib; };
#
#   link-farm-entries "" { serverExe = { wasm = <drv>; recurseForDerivations = true; }; }
#   => [ { name = "serverExe/wasm"; path = <drv>; } ]
#
#   link-farm-entries "" { recurseForDerivations = true; }
#   => [ ]
{ lib }:

let entries = prefix: value:
      let childName = name:
            if prefix == "" then name else "${prefix}/${name}";
          children = removeAttrs value [ "recurseForDerivations" ];
      in if lib.isDerivation value
         then [ { name = prefix; path = value; } ]
         else lib.concatLists (lib.mapAttrsToList
           (name: entry: entries (childName name) entry)
           children);

in entries

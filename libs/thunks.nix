# Resolve every subdirectory of `dir` through ./thunk.nix, giving an attrset of
# dependency name to source. Equivalent to nix-thunk's
# `mapSubdirectories thunkSource`.
#
# Example:
#
#   import ./thunks.nix ../pins
#   => { haskell-nix = <source>; nixpkgs = <source>; }
dir:
let entries = builtins.readDir dir;
    thunkSource = import ./thunk.nix;
in builtins.listToAttrs (map
     (name: { inherit name; value = thunkSource (dir + "/${name}"); })
     (builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries)))

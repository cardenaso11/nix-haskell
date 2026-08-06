# Decode one `source-repository-packages` entry. A spec is a path, a packed
# thunk, anything with an outPath, or an attrset with `src` and optional
# `subdir` and `condition`.
#
# Example:
#
#   decode { src = ./dep; subdir = [ "a" "b" ]; condition = "!arch(javascript)"; }
#   => { src = <resolved ./dep>;
#        condition = "!arch(javascript)";
#        subdirs = [ "a" "b" ];
#        hasOutPath = false;
#      }
#
#   decode ./dep
#   => { src = <resolved ./dep>; condition = null; subdirs = []; hasOutPath = false; }
#
#   decode inputs.reflex-dom     # a flake input, or anything with an outPath
#   => { src = inputs.reflex-dom; # the spec itself, already in the store, so
#        condition = null;        # the caller copies nothing
#        subdirs = [];
#        hasOutPath = true;
#      }

let thunkSource = import ./thunk.nix;

    toList = x: if builtins.isList x then x else [ x ];

in spec:

let hasOutPath = builtins.isAttrs spec && spec ? outPath;
    attrs = if builtins.isAttrs spec && !hasOutPath then spec else {};

in {
  inherit hasOutPath;
  src = thunkSource (if attrs ? src then attrs.src else spec);
  condition = attrs.condition or null;
  subdirs = if attrs ? subdir then toList attrs.subdir else [];
}

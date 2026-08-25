# The settings an optimizer runs with, resolved from the layers a project
# can state them on. The most specific layer that states a field decides it,
# in this order:
#
# 1. One executable of a package, built for one cross target.
# 2. That package for that target.
# 3. That target as a whole.
# 4. The same executable, then the same package, whatever the target.
# 5. The tool's own defaults, the only layer that carries every field, so
#    every field is answered.
#
# `null` states nothing. An optimizer told no names takes the defaults
# whole. A target, package or executable with no entry states nothing
# rather than an error. A tool this repo does not bundle has no typed
# options on the layers. It states them through `bundle-optimizers`
# instead.
#
# Example:
#
#   settings = import ./settings.nix { inherit lib; };
#
#   settings {
#     tool = "wasm-opt";
#     defaults = {
#       enable = true;
#       level = "2";
#       extraFlags = [ "-ol 2" "-s 1" "--low-memory-unused" "--strip-dwarf" "--converge" ];
#     };
#     platforms.wasi32 = {
#       wasm-opt = { enable = null; level = "z"; extraFlags = null; };
#       packages.frontend = {
#         wasm-opt = { enable = null; level = null; extraFlags = [ "--converge" ]; };
#         components.exes.frontend.wasm-opt = { enable = null; level = null; extraFlags = null; };
#       };
#     };
#     packages = {};
#     platform = "wasi32";
#     package = "frontend";
#     exe = "frontend";
#   }
#   => { enable = true;                  # the defaults, the only layer to state it
#        level = "z";                    # this target, nothing more specific stating one
#        extraFlags = [ "--converge" ];  # this package on this target
#      }
#
#   settings {
#     tool = "closure-compiler";
#     defaults = {
#       enable = true;
#       level = "ADVANCED";
#       externs = [];
#       extraFlags = [ "--language_in UNSTABLE" "--warning_level QUIET" ];
#     };
#   }
#   => the defaults, whole: an optimizer told no names has no other layer to
#      read
#
#   settings {
#     tool = "probe-opt";
#     defaults = { enable = true; };
#     platforms.wasi32.packages.frontend = {};
#     platform = "wasi32";
#     package = "frontend";
#   }
#   => { enable = true; }: layers that do not carry the tool state nothing
{ lib }:

{ tool, defaults, packages ? {}, platforms ? {}, platform ? null, package ? null, exe ? null }:

let # One layer's statement of the tool: its typed options when the tool is
    # bundled, its raw `bundle-optimizers` entry otherwise, null when it
    # says nothing.
    layerOf = entry: entry.${tool} or (entry.bundle-optimizers.${tool} or null);

    # What a `packages` tree states, the executable's own layer ahead of the
    # whole package's. A layer without the tool is null here: it states
    # nothing.
    layersIn = tree:
      let named = package != null && tree ? ${package};
          entry = tree.${package};
          exes = entry.components.exes or {};
      in lib.optional (named && exe != null && exes ? ${exe}) (layerOf exes.${exe})
      ++ lib.optional named (layerOf entry);

    onTarget = platform != null && platforms ? ${platform};

    target = platforms.${platform};

    stated = value: value != null;

    layers =
      lib.filter stated (
        lib.optionals onTarget (layersIn target.packages ++ [ (layerOf target) ])
        ++ layersIn packages)
      ++ [ defaults ];

    firstStated = lib.zipAttrsWith (_: lib.findFirst stated null);

in firstStated layers

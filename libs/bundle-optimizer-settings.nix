# The settings an optimizer runs with, resolved from the layers a project can
# state them on. From most specific to least: one executable of a package built
# for one cross target, that package for that target, that target as a whole,
# then the same executable and package whatever the target, and last the tool's
# own defaults. The most specific layer that states a field decides it, and
# `null` states nothing. Only the defaults carry every field, so all of them are
# answered.
#
# A target, package or executable with no entry is a layer that states nothing
# rather than an error: the settings are optional at every layer, and an
# optimizer is told these names only to pick up whatever was said about them.
#
# Example:
#
#   settings = import ./bundle-optimizer-settings.nix { inherit lib; };
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
#     tool = "closure";
#     defaults = {
#       enable = true;
#       level = "ADVANCED";
#       externs = [];
#       extraFlags = [ "--language_in UNSTABLE" "--warning_level QUIET" ];
#     };
#   }
#   => { enable = true;                  # an optimizer told no names takes the
#        level = "ADVANCED";             # defaults whole
#        externs = [];
#        extraFlags = [ "--language_in UNSTABLE" "--warning_level QUIET" ];
#      }
{ lib }:

{ tool, defaults, packages ? {}, platforms ? {}, platform ? null, package ? null, exe ? null }:

let # What a `packages` tree states, the executable's own layer ahead of the
    # whole package's.
    layersIn = tree:
      let named = package != null && tree ? ${package};
          entry = tree.${package};
          exes = entry.components.exes;
      in lib.optional (named && exe != null && exes ? ${exe}) exes.${exe}.${tool}
      ++ lib.optional named entry.${tool};

    onTarget = platform != null && platforms ? ${platform};

    target = platforms.${platform};

    stated = value: value != null;

in lib.zipAttrsWith (_: lib.findFirst stated null)
     (lib.optionals onTarget (layersIn target.packages ++ [ target.${tool} ])
      ++ layersIn packages
      ++ [ defaults ])

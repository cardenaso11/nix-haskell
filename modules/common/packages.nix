# The `packages` option: per-package customization, keyed by cabal
# package name.
{ lib, packageFields, bundleOptimizerLayer, bundleOptimizersOption }:

with lib;
with (import ../../libs/prelude { inherit lib; });

{

  packages = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        src = mkOption {
          type = types.nullOr (types.either types.path types.package);
          default = null;
          description = ''
            Replacement source for the package.
          '';
          example = fenced-code ''./vendored/my-dep'';
        };
        components = mkOption {
          type = types.submodule {
            options.exes = mkOption {
              type = types.attrsOf (types.submodule {
                options = {
                  inherit (bundleOptimizerLayer) wasm-opt closure-compiler;
                  bundle-optimizers = bundleOptimizersOption;
                };
              });
              default = {};
              description = ''
                Bundle optimizer settings for one executable of the
                package, keyed by the name cabal gives it. They sit under
                an executable rather than the package, because a bundle
                belongs to one linked executable. A package can carry
                several.

                Naming an executable here also tells the haskell.nix
                driver to install that executable's `.jsexe` directory,
                which it otherwise leaves in the build tree.
              '';
            };
          };
          default = {};
          description = ''
            Per-component customization, grouped by the component kind
            cabal uses. Only executables carry anything so far.
          '';
        };
        inherit (bundleOptimizerLayer) wasm-opt closure-compiler;
        bundle-optimizers = bundleOptimizersOption;
      } // packageFields.options;
    });
    default = {};
    description = ''
      Per-package customization, keyed by cabal package name. A driver
      ignores an entry for a package that is not in the final package
      set, and warns about nothing, so a platform-conditional package can
      be customized unconditionally.
    '';
    example = fenced-code ''
      {
        splitmix.patches = [ ./splitmix-js.patch ];
        reflex-dom-core.doCheck = false;
        my-app.flags.production = true;
      }
    '';
  };

}

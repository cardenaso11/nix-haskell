# GHCJS Cross-Compilation Support Module
#
# Provides GHCJS detection and configures shell dependencies for JavaScript
# compilation targets. GHCJS compiles Haskell to JavaScript, requiring Node.js
# template haskell.
#
# This module:
#   - Detects whether GHCJS is the current target (native or cross-compilation)
#   - Adds Node.js to shell.buildInputs when GHCJS is detected
#   - Carries what a project does with a linked `.jsexe` once a driver has built
#     it: `js-optimize` for the closure-compiler pass over its `all.js`, settled
#     by the `closure-compiler` settings
#
# The `isGhcjs` option uses a two-part detection strategy:
#   1. Direct check: Is the host platform GHCJS? (native GHCJS build)
#   2. Cross-compilation check: Is GHCJS selected in shell.crossPlatforms?
#
# The cross-compilation detection works by creating a probe set that maps
# platform names to themselves (e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; }).
# When crossPlatforms selects from this set, it returns platform name strings,
# allowing simple membership testing with `builtins.elem "ghcjs"`.

{ config, lib, pkgs, ... }:

with lib;

let bundleOptimizer = import ../../../libs/bundle-optimizer-options.nix { inherit lib; };

    bundleSettings = import ../../../libs/bundle-optimizer-settings.nix { inherit lib; };

    functionOption = import ../../../libs/function-option.nix { inherit lib; };

in {

  options = {

    isGhcjs = mkOption {
      type = types.bool;
      default =
        let # Create probe set mapping each platform name to itself
            # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
            probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
            # Get list of selected platform names as strings
            selected = config.shell.crossPlatforms probeSet;
        in # Native GHCJS: the shell itself is for a GHCJS platform
              pkgs.stdenv.hostPlatform.isGhcjs
           # Cross-compilation: GHCJS is among the selected cross targets
           || builtins.elem "ghcjs" selected;
      defaultText = ''
        let # Create probe set mapping each platform name to itself
            # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
            probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
            # Get list of selected platform names as strings
            selected = config.shell.crossPlatforms probeSet;
        in # Native GHCJS: the shell itself is for a GHCJS platform
              pkgs.stdenv.hostPlatform.isGhcjs
           # Cross-compilation: GHCJS is among the selected cross targets
           || builtins.elem "ghcjs" selected;
      '';
      description = ''
        Whether the project targets GHCJS (either natively or via cross-compilation).
        Used to conditionally include JavaScript runtime dependencies.
      '';
    };

    closure-compiler = bundleOptimizer.closure-compiler;

    js-optimize = functionOption {
      default = { platform ? null, package ? null, exe ? null, jsexe }:
        import ../../../libs/closure-compiler/run.nix { inherit pkgs lib; }
          ({ inherit jsexe; } // bundleSettings {
            tool = "closure-compiler";
            defaults = config.closure-compiler;
            inherit (config) packages platforms;
            inherit platform package exe;
          });
      defaultText = literalMD ''
        ```
        <nix-haskell>/libs/closure-compiler/run.nix, run with the settings the
        named target, package and executable resolve to
        ```
      '';
      description = ''
        A linked `.jsexe` directory with its `all.js` closure-compiled, the rest
        of the directory as it was. It takes the directory rather than the
        package that carries it:

        ```
        js-optimize {
          platform = "ghcjs";
          package = "frontend";
          exe = "frontend";
          jsexe = "''${frontend}/bin/frontend.jsexe";
        }
        ```

        The three names are only what the settings are looked up under, and any
        of them can be left out to say nothing about it. `closure-compiler` is
        read from the layer that states a field most specifically to the least:
        `platforms.<platform>.packages.<package>.components.exes.<exe>.closure-compiler`,
        `platforms.<platform>.packages.<package>.closure-compiler`,
        `platforms.<platform>.closure-compiler`, then the same package and
        executable layers of `packages`, and last `closure-compiler` itself,
        which is the only one holding values throughout. They are read from the project's own values
        rather than a driver's, since this runs on a built artifact, outside
        any driver.
      '';
    };

  };

  config = {

    shell = {

      # Node.js is required for template haskell
      buildInputs = mkIf config.isGhcjs (with pkgs; [
        nodejs-slim
      ]);

    };

  };

}

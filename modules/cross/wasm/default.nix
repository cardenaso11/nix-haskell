# WASM Cross-Compilation Support Module
#
# Provides WASM detection and configures shell dependencies for WebAssembly
# compilation targets. WASM compiles Haskell to WebAssembly, requiring Node.js
# for template haskell.
#
# This module:
#   - Detects whether WASM is the current target (native or cross-compilation)
#   - Adds Node.js to shell.buildInputs when WASM is detected
#   - Carries what a project does with a wasm binary once a driver has built
#     it: `wasm-optimize` for wasm-opt and the strip that follows it, settled
#     by the `wasm-opt` settings, and `wasm-jsffi` for the JavaScript a wasm
#     module cannot be instantiated without
#
# The `isWasm` option uses a two-part detection strategy:
#   1. Direct check: Is the host platform WASM? (native WASM build)
#   2. Cross-compilation check: Is a WASM target selected in shell.crossPlatforms?
#
# The cross-compilation detection works by creating a probe set that maps
# platform names to themselves (e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; }).
# When crossPlatforms selects from this set, it returns platform name strings,
# allowing membership testing with `builtins.any`.

{ config, lib, pkgs, ... }:

with lib;

let bundleOptimizer = import ../../../libs/bundle-optimizer-options.nix { inherit lib; };

    bundleSettings = import ../../../libs/bundle-optimizer-settings.nix { inherit lib; };

in {

  options = {

    isWasm = mkOption {
      type = types.bool;
      default =
        let # Create probe set mapping each platform name to itself
            # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
            probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
            # Get list of selected platform names as strings
            selected = config.shell.crossPlatforms probeSet;
        in # Native WASM: the shell itself is for a WASM platform
              pkgs.stdenv.hostPlatform.isWasm
           # Cross-compilation: a WASM target is among the selected cross targets
           || builtins.any (name: hasInfix "wasm" name || hasPrefix "wasi" name) selected;
      defaultText = ''
        let # Create probe set mapping each platform name to itself
            # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
            probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
            # Get list of selected platform names as strings
            selected = config.shell.crossPlatforms probeSet;
        in # Native WASM: the shell itself is for a WASM platform
              pkgs.stdenv.hostPlatform.isWasm
           # Cross-compilation: a WASM target is among the selected cross targets
           || builtins.any (name: hasInfix "wasm" name || hasPrefix "wasi" name) selected;
      '';
      description = ''
        Whether the project targets WASM (either natively or via cross-compilation).
        Used to conditionally include WebAssembly runtime dependencies.
      '';
    };

    wasm-opt = bundleOptimizer.wasm-opt;

    wasm-optimize = mkOption {
      type = types.functionTo types.package;
      default = { platform ? null, package ? null, exe ? null, wasm }:
        import ../../../libs/wasm-opt.nix { inherit pkgs lib; }
          ({ inherit wasm; } // bundleSettings {
            tool = "wasm-opt";
            defaults = config.wasm-opt;
            inherit (config) packages platforms;
            inherit platform package exe;
          });
      defaultText = literalMD ''
        ```
        <nix-haskell>/libs/wasm-opt.nix, run with the settings the named target,
        package and executable resolve to
        ```
      '';
      description = ''
        A wasm binary optimized and stripped. It takes the file rather than the
        package that carries it, and yields the file rather than a directory
        holding it, so the caller installs it under whatever name it wants:

        ```
        wasm-optimize {
          platform = "wasi32";
          package = "frontend";
          exe = "frontend";
          wasm = "''${frontend}/bin/frontend.wasm";
        }
        ```

        The three names are only what the settings are looked up under, and any
        of them can be left out to say nothing about it. `wasm-opt` is read
        from the layer that states a field most specifically to the least:
        `platforms.<platform>.packages.<package>.components.exes.<exe>.wasm-opt`,
        `platforms.<platform>.packages.<package>.wasm-opt`,
        `platforms.<platform>.wasm-opt`, then the same package and executable
        layers of `packages`, and last `wasm-opt` itself, which is the only one
        holding values throughout. They are read from the project's own values
        rather than a driver's, since this runs on a built artifact, outside
        any driver.
      '';
    };

    wasm-jsffi = mkOption {
      type = types.functionTo types.package;
      default = { ghc, wasm }:
        import ../../../libs/wasm-jsffi.nix { inherit pkgs; } { inherit ghc wasm; };
      defaultText = literalMD ''
        ```
        <nix-haskell>/libs/wasm-jsffi.nix
        ```
      '';
      description = ''
        The `ghc_wasm_jsffi.js` a GHC-built wasm module needs to be
        instantiated at all, read out of the binary by the compiler that built
        it:

        ```
        wasm-jsffi {
          ghc = config.<driver>.cross-compiler "wasi32";
          wasm = "''${frontend}/bin/frontend.wasm";
        }
        ```

        The compiler must be the one that produced the binary, which is what
        `<driver>.cross-compiler` names. Run this on the binary as linked,
        before `wasm-optimize` strips the sections it reads.
      '';
    };

  };

  config = {

    shell = {

      # Node.js is required for template haskell
      buildInputs = mkIf config.isWasm (with pkgs; [
        nodejs
      ]);

    };

  };

}

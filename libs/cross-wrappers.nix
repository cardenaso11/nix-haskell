# Cross-compiler wrapper scripts, shared by the drivers.
#
# Given a cross GHC, produces a script named after its target prefix that runs
# a command with the prefix-less tool names in PATH:
#
#   wasm32-unknown-wasi ghc --version     # instead of wasm32-unknown-wasi-ghc
#   wasm32-unknown-wasi ghc-pkg list
#
# Each driver calls this with the GHCs of the cross platforms selected by
# `shell.crossPlatforms` and adds the results to its shell's buildInputs.
{ pkgs, lib }:

ghc:

let # Target prefix without trailing dash (e.g. "wasm32-unknown-wasi-" -> "wasm32-unknown-wasi")
    targetPrefix = lib.removeSuffix "-" ghc.targetPrefix;
    targetPrefixes = [ targetPrefix ] ++ lib.optional (lib.hasInfix "wasm" targetPrefix) "wasm";
    prefixPattern = lib.concatMapStringsSep "|" (p: "*${p}*") targetPrefixes;

    # Directory with symlinks: wasm32-unknown-wasi-ghc -> ghc, etc.
    # Allows tools to be called without prefix when this dir is in PATH
    ghcWrapper = pkgs.runCommand "${targetPrefix}-ghc-wrapper" {} ''
        mkdir -p $out/bin
        for i in ${ghc.outPath}/bin/${targetPrefix}-*; do
          name=$(basename "$i")
          ln -s "$i" $out/bin/''${name#${targetPrefix}-}
        done
      '';

# Only create wrapper for cross-compilation (skip if no target prefix)
in lib.optional ((targetPrefix != null) && (targetPrefix != ""))
    (
      # Script named after target that runs commands with wrapper in PATH
      pkgs.writeShellScriptBin "${targetPrefix}" ''
        # Filter linker flags to keep only cross-target library paths. The
        # dev shell includes both native and cross-compiled dependencies, so
        # NIX_LDFLAGS contains both native and target library paths. Passing
        # native shared objects (e.g., native libffi.so) to the cross-linker
        # causes "unknown file type" errors.
        _filter_ldflags() {
          local result=""
          for arg in $1; do
            if [[ "$arg" == -L* ]]; then
              case "$arg" in
                ${prefixPattern}) result="$result $arg" ;;
                *) ;;
              esac
            else
              result="$result $arg"
            fi
          done
          echo "$result"
        }
        export NIX_LDFLAGS="$(_filter_ldflags "${"\${NIX_LDFLAGS_UNFILTERED:-$NIX_LDFLAGS}"}")"
        export NIX_LDFLAGS_FOR_TARGET="$(_filter_ldflags "${"\${NIX_LDFLAGS_FOR_TARGET_UNFILTERED:-$NIX_LDFLAGS_FOR_TARGET}"}")"
        PATH="${ghcWrapper}/bin:$PATH" exec "$@"
      ''
    )

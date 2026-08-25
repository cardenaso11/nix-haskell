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
#
# Example:
#
#   import ./wrappers.nix { inherit pkgs lib; } wasiCrossGhc
#   => [ <a "wasm32-unknown-wasi" script in a derivation> ]
#
#   import ./wrappers.nix { inherit pkgs lib; } nativeGhc
#   => [ ]                                     # no target prefix, no wrapper
{ pkgs, lib }:

ghc:

let targetPrefix = lib.removeSuffix "-" ghc.targetPrefix;
    targetPrefixes = [ targetPrefix ] ++ lib.optional (lib.hasInfix "wasm" targetPrefix) "wasm";
    prefixPattern = lib.concatMapStringsSep "|" (p: "*${p}*") targetPrefixes;

    ghcWrapper = pkgs.runCommand "${targetPrefix}-ghc-wrapper" {} ''
        mkdir -p $out/bin
        for i in ${ghc.outPath}/bin/${targetPrefix}-*; do
          name=$(basename "$i")
          ln -s "$i" $out/bin/''${name#${targetPrefix}-}
        done
      '';

in lib.optional ((targetPrefix != null) && (targetPrefix != ""))
    (
      pkgs.writeShellScriptBin "${targetPrefix}" ''
        # The dev shell carries both native and cross-compiled dependencies,
        # so NIX_LDFLAGS names library paths for both. A native shared
        # object (native libffi.so) handed to the cross linker fails with
        # "unknown file type", so only the cross-target paths pass.
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
        export NIX_LDFLAGS="$(_filter_ldflags "''${NIX_LDFLAGS_UNFILTERED:-$NIX_LDFLAGS}")"
        export NIX_LDFLAGS_FOR_TARGET="$(_filter_ldflags "''${NIX_LDFLAGS_FOR_TARGET_UNFILTERED:-$NIX_LDFLAGS_FOR_TARGET}")"
        PATH="${ghcWrapper}/bin:$PATH" exec "$@"
      ''
    )

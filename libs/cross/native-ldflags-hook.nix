# The shell hook a shell with cross targets runs. NIX_LDFLAGS names
# library directories for both the native and the cross side, and each
# linker fails on the other side's objects. The hook drops every
# selected target's -L paths from the native variables. The unfiltered
# values stay in the environment for the cross wrappers to start from.
#
# Example:
#
#   import ./native-ldflags-hook.nix { inherit pkgs lib; } { platforms = [ "ghcjs" "wasi32" ]; }
#   => shell lines defining _filter_native_ldflags with the case pattern
#      "*javascript-unknown-ghcjs*|*wasm32-unknown-wasi*|*wasm*", capturing
#      NIX_LDFLAGS_UNFILTERED and NIX_LDFLAGS_FOR_TARGET_UNFILTERED once,
#      and exporting the filtered NIX_LDFLAGS and NIX_LDFLAGS_FOR_TARGET
{ pkgs, lib }:

{ platforms }:

let platformConfigs = map
      (name: pkgs.pkgsCross.${name}.stdenv.hostPlatform.config)
      platforms;

    prefixes = lib.filter (p: p != "") platformConfigs;

    targetPrefixes =
      prefixes ++ lib.optional (builtins.any (p: lib.hasInfix "wasm" p) prefixes) "wasm";

    prefixPattern = lib.concatMapStringsSep "|" (p: "*${p}*") targetPrefixes;

in ''
  _filter_native_ldflags() {
    local result=""
    for arg in $1; do
      if [[ "$arg" == -L* ]]; then
        case "$arg" in
          ${prefixPattern}) ;;
          *) result="$result $arg" ;;
        esac
      else
        result="$result $arg"
      fi
    done
    echo "$result"
  }

  # Capture the unfiltered flags only once: a re-run of the hook must not
  # overwrite them with filtered values, or the cross wrappers filter a
  # filtered list and keep nothing. The `-` form, not `:-`, keeps an empty
  # capture.
  export NIX_LDFLAGS_UNFILTERED="''${NIX_LDFLAGS_UNFILTERED-$NIX_LDFLAGS}"
  export NIX_LDFLAGS_FOR_TARGET_UNFILTERED="''${NIX_LDFLAGS_FOR_TARGET_UNFILTERED-$NIX_LDFLAGS_FOR_TARGET}"
  export NIX_LDFLAGS="$(_filter_native_ldflags "$NIX_LDFLAGS")"
  export NIX_LDFLAGS_FOR_TARGET="$(_filter_native_ldflags "$NIX_LDFLAGS_FOR_TARGET")"
''

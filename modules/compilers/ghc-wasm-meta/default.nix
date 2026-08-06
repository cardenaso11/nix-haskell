# ghc-wasm-meta's wasm GHC as the compiler for a wasm target. A bindist carries
# none of the attributes the drivers read off a compiler, so they are supplied
# here rather than by every project that wants one, along with the wasi-sdk the
# bindist was configured with, which everything built has to be pointed at.
#
# `flavour` is the GHC series to take from the pin. `version` is worth passing
# for a nightly, whose derivation name carries only that series: both drivers
# work either way, but what they fall back to for the builds that cannot use
# the bindist itself (a package set to solve against, the shell's tools)
# follows the version, so a full one keeps those on the release it came from.
#
# Example:
#
#   { nix-haskell-compilers, ... }:
#   {
#     imports = [
#       (import "${nix-haskell-compilers}/ghc-wasm-meta" {
#         flavour = "9.12";
#         version = "9.12.4.20260731";
#       })
#     ];
#   }
{ platform ? "wasi32", flavour, version ? null, drivers ? null }:

{ config, lib, pkgs, ... }:

let src = config.inputs.ghc-wasm-meta;

    ghc = pkgs.callPackage "${src}/pkgs/wasm32-wasi-ghc.nix" { inherit flavour; };

    sdk = pkgs.callPackage "${src}/pkgs/wasi-sdk.nix" {};

    compiler = {
      platforms.${platform} = {
        package = ghc;
        inherit version;
        targetPrefix = "wasm32-wasi-";

        # the wasm backend's Template Haskell interpreter loads shared objects
        enableShared = true;

        # the bindist keeps its package database and settings directly under
        # lib, rather than under the lib/<prefix>ghc-<version>/lib of a
        # version-named install
        haskell-nix.libDir = "lib";

        # the wasm backend runs Template Haskell itself, so splices must not be
        # proxied to the target, which has no sockets to proxy over
        nixpkgs.enableExternalInterpreter = false;

        toolchain = {
          package = sdk;
          # the names the sdk's own setup hook exports as CC, AR, LD and STRIP
          cc = "wasm32-wasi-clang";
          ar = "llvm-ar";
          ld = "wasm-ld";
          strip = "llvm-strip";
        };
      };
    };

in {

  # `drivers` selects the drivers the compiler applies to; null gives it to all
  # of them.
  config =
    if drivers == null
    then { inherit compiler; }
    else builtins.listToAttrs
      (map (driver: { name = driver; value = { inherit compiler; }; }) drivers);

}

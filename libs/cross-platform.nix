# What a cross platform name means. The names are `pkgs.pkgsCross`
# attribute names, which is what the options keyed by platform expect, and a
# name that denotes no platform is an error rather than something that quietly
# never matches.
#
# Example:
#
#   platforms = import ./cross-platform.nix { inherit lib; };
#   platforms.matches "wasi32" <an elaborated wasm32-wasi platform>  => true
#   platforms.keyFor [ "ghcjs" "wasi32" ] <elaborated wasm32-wasi>   => "wasi32"
#   platforms.keyFor [ "ghcjs" ] <elaborated wasm32-wasi>            => null
#   (platforms.targetFor "wasi32").isWasm                            => true
#   (platforms.targetFor "ghcjs").isGhcjs                            => true
{ lib }:

with lib;

rec {

  targetFor = key:
    let example = systems.examples.${key}
          or (throw ("nix-haskell: \"${key}\" names neither the native system"
            + " nor a pkgsCross platform"));
    in systems.elaborate example;

  matches = key: targetPlatform:
    (targetFor key).config == targetPlatform.config;

  keyFor = keys: targetPlatform:
    findFirst (key: matches key targetPlatform) null keys;

}

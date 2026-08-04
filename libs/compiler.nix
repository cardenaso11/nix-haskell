# The common `compiler` option interpreted: per-platform resolution to a
# name and an optional package.
#
# A bare spec applies to every platform; an attrset keyed by platform (the
# native system and pkgsCross names) resolves each platform to its own
# entry, and platforms without one throw when accessed. A string spec is a
# compiler name, looked up in the driver's package sets
# (haskell-nix.compiler.<name>, pkgs.haskell.packages.<name>). A package
# spec is used directly; its name is taken from a `compiler-nix-name`
# attribute when the package carries one, and derived from its version
# otherwise ("9.12.2" -> "ghc9122"). `toolsName` is the stock compiler
# matching the package's major.minor.patch version, for auxiliary builds
# (haskell.nix shell tools) that cannot use the package itself.
#
# Example:
#
#   compilers = import ./compiler.nix { inherit lib; } {
#     x86_64-linux = "ghc912";
#     wasi32 = wasmGhc;
#   };
#   => { perPlatform = true;
#        resolve = <platform: { name; package; toolsName; }>;
#        targetKey = <nativeSystem: targetPlatform: platform>;
#      }
#   compilers.resolve "x86_64-linux"
#   => { name = "ghc912"; package = null; toolsName = "ghc912"; }
#   compilers.resolve "wasi32"
#   => { name = "ghc9122120250327"; package = wasmGhc; toolsName = "ghc9122"; }
{ lib }:

with lib;

value:
let perPlatform = isAttrs value && ! isDerivation value;

    specFor = platform:
      if perPlatform
      then value.${platform} or (throw ("nix-haskell: `compiler` has no entry for ${platform}"
        + " (available: ${concatStringsSep ", " (attrNames value)})"))
      else value;

in rec {

  inherit perPlatform;

  resolve = platform:
    let spec = specFor platform;
    in
    if isString spec
    then { name = spec; package = null; toolsName = spec; }
    else
      let version = getVersion spec;
          derive = f:
            if version == ""
            then throw ("nix-haskell: cannot derive a compiler name from "
              + "${spec.name or "<compiler package>"}: it carries no version; "
              + "add a `version` or `compiler-nix-name` attribute to the package")
            else f version;
      in {
        name = spec.compiler-nix-name or
          (derive (v: "ghc" + replaceStrings [ "." ] [ "" ] v));
        package = spec;
        toolsName = spec.compiler-nix-name or
          (derive (v: "ghc" + concatStrings (take 3 (splitVersion v))));
      };

  # The attrset key matching a target platform: the native system for a
  # bare spec or a native target, else the pkgsCross name with the same
  # target triple.
  targetKey = nativeSystem: targetPlatform:
    let crossKeys = filter (k: k != nativeSystem) (attrNames value);
        matches = k: (systems.elaborate (systems.examples.${k}
          or (throw ("nix-haskell: `compiler` key \"${k}\" is not the native"
            + " system or a pkgsCross platform")))).config == targetPlatform.config;
    in if ! perPlatform || targetPlatform.system == nativeSystem
       then nativeSystem
       else findFirst matches
         (throw "nix-haskell: no `compiler` entry for target ${targetPlatform.config}")
         crossKeys;

}

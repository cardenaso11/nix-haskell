# A haskell.nix module pointing a project's builds at the compiler's own C
# toolchain. The components of a cross project are built by the cross package
# set's stdenv, whose toolchain is not the one the compiler was configured
# with, so anything reaching for C during a build looks in the wrong sysroot:
# `Setup configure`'s foreign-dependency checks fail on headers that are
# present, and what does compile is built for a different ABI than the
# compiler's own libraries.
#
# The module goes into every project the driver builds, including the ones for
# the build platform, and decides per evaluation whether it applies: only a
# platform with an entry of its own, carrying a toolchain, is affected.
#
# Example:
#
#   import ./compiler-toolchain.nix { inherit lib compilers; }
#   => <a haskell.nix module>
{ lib, compilers }:

{ config, pkgs, ... }:

let key = compilers.targetKey pkgs.stdenv.hostPlatform;

    compiler = compilers.resolve key;

    # `resolve` falls back to the compiler above the platform table, so the key
    # is what says whether this platform has an entry of its own. Without that
    # check a native toolchain would follow the build into every cross target.
    ownToolchain = key != null && compiler.toolchain.package != null;

in {

  # `mkIf` rather than a conditional module body: `pkgs` reaches a module
  # through `_module.args`, so deciding the module's own attributes on it is a
  # cycle.
  config = lib.mkIf ownToolchain {
    packages = lib.genAttrs config.package-keys (_: {
      configureFlags = compiler.toolchainFlags;
    });
  };

}

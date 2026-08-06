# A haskell.nix module installing an executable's `.jsexe` directory beside the
# executable itself. The js backend links a program into `<exe>.jsexe/all.js` and
# a single bundled `<exe>` next to it, and this builder installs only the second,
# while `js-optimize` needs the directory: the `all.externs.js` the linker leaves
# there is what keeps closure-compiler from renaming the names the runtime
# reaches by name. The nixpkgs builder copies the directory out on its own, so
# there is nothing to do on that side.
#
# The executables are the ones a project named under
# `packages.<name>.components.exes`. Nothing else says which executables a
# package has: asking the module system would mean deriving these definitions
# from the very keys they add.
#
# Example:
#
#   import ./install-jsexe.nix { inherit lib; exes = { frontend = [ "frontend" ]; }; }
#   => a haskell.nix module which, in the project whose target is javascript,
#      gives
#
#        packages.frontend.components.exes.frontend.postInstall = ''
#          if [ -d dist/build/frontend/frontend.jsexe ]; then
#            cp -r dist/build/frontend/frontend.jsexe $out/bin/
#          fi
#        '';
#
#      and in a project for any other target, or one where frontend is not a
#      package of the project at all, nothing
{ lib, exes }:

{ config, pkgs, ... }:

let install = exe: ''
      if [ -d dist/build/${exe}/${exe}.jsexe ]; then
        cp -r dist/build/${exe}/${exe}.jsexe $out/bin/
      fi
    '';

    named = lib.filterAttrs (name: _: config.packages ? ${name}) exes;

in {

  # `mkIf` rather than a conditional body: `pkgs` reaches a module through
  # `_module.args`, so deciding the module's own attributes on it is a cycle.
  config = lib.mkIf pkgs.stdenv.hostPlatform.isGhcjs {
    packages = lib.mapAttrs (_: names: {
      components.exes = lib.genAttrs names (exe: { postInstall = install exe; });
    }) named;
  };

}

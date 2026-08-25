# The project source options: where the project comes from, and the
# gitignore filtering it goes through on its way into the store.
{ lib, pkgs, config }:

with lib;

{

  src = mkOption {
    type = types.either types.path types.package;
    example = "./.";
    description = ''
      The project source: the tree holding the cabal project file and the
      packages it names.

      - A path is copied into the store, filtered first when `clean-src`
        is enabled.
      - A derivation or a store path is used as it is, because whatever
        produced it already chose what it contains.
    '';
  };

  clean-src = mkOption {
    type = types.bool;
    default = true;
    description = ''
      Filter `src` through the `.gitignore` it carries before copying it
      into the store. Build artifacts (`dist-newstyle`, `result`, `.git`)
      then do not become part of every derivation that names the project
      source. A rebuild then does not rehash them. This applies only when
      `src` is a path. A derivation is used as-is.
    '';
  };

  clean-src-ignore-files = mkOption {
    type = types.listOf types.str;
    default = [ "/.gitignore" ];
    description = ''
      The ignore files read when `clean-src` is enabled. Paths are
      relative to the root of the source tree.

      Every pattern uses the root as its base, whichever file it came
      from. An anchored pattern in a nested file (`dist/*`) therefore
      matches against the root, not against the file's own directory.
      Where that matters, add the pattern to `clean-src-patterns` instead.
    '';
    example = [ "/.gitignore" "/frontend/.gitignore" ];
  };

  clean-src-patterns = mkOption {
    type = types.lines;
    default = "";
    description = ''
      Extra gitignore-syntax patterns, applied on top of the files
      `clean-src-ignore-files` names, when `clean-src` is enabled. A bare
      pattern (`dist-js`) matches at any depth. An anchored pattern read
      against the root cannot.
    '';
    example = ''
      dist-wasm
      dist-js
    '';
  };

  src-cleaned = mkOption {
    type = types.either types.path types.package;
    readOnly = true;
    default =
      if config.clean-src
      then import ../../libs/clean-source.nix { inherit pkgs; } {
             src = config.src;
             name = config.name;
             ignoreFiles = config.clean-src-ignore-files;
             patterns = config.clean-src-patterns;
           }
      else config.src;
    defaultText = literalMD ''
    ```
      import ../../libs/clean-source.nix { inherit pkgs; } {
        src = config.src;
        name = config.name;
        ignoreFiles = config.clean-src-ignore-files;
        patterns = config.clean-src-patterns;
      }
    ```
    '';
    description = ''
      `src` with build artifacts filtered out, or `src` itself when
      `clean-src` is disabled. The drivers build the project from this.
    '';
  };

}

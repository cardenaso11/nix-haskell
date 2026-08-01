{ pkgs }:

with pkgs.lib;

let thunkSource = import ./thunk.nix;

    # source-repository-package
    # :: String -> (Path || Thunk || { src :: Path || Thunk; condition :: String || Null } || { outPath :: Path; ... })
    # -> { inputMap."Path" :: AttrSet; cabalProject :: String }
    source-repository-package = name: package-repo:
      let hasOutPath = builtins.isAttrs package-repo && package-repo ? outPath;
          src = thunkSource
            ( if hasOutPath then package-repo
              else if builtins.isAttrs package-repo && package-repo ? src then package-repo.src
              else package-repo
            );
          condition = if !hasOutPath && builtins.isAttrs package-repo && package-repo ? condition then package-repo.condition else null;
          resolved = if hasOutPath then package-repo else { inherit name; outPath = builtins.path { path = src; inherit name; }; };
          # Same string as before, but with its context intact, so that a
          # derivation embedding it (see libs/src-driver.nix) registers a
          # reference to the source it names. `input` is only ever used as an
          # attribute name, where context is not permitted, and that is the one
          # place it still has to be discarded.
          location = "${src}";
          input = builtins.unsafeDiscardStringContext location;
      in {
        inputMap.${input} = resolved // { rev = "HEAD"; };
        cabalProject =
          if condition == null
          then ''
            source-repository-package
              type: git
              location: ${location}
              tag: HEAD
          ''
          else ''
            if ${condition}
              source-repository-package
                type: git
                location: ${location}
                tag: HEAD
          '';
      };

    # source-repository-packages
    # :: AttrSet (String -> Path || ...) -> { inputMap :: AttrSet; cabalProject :: String }
    source-repository-packages = package-repos:
      let packages = mapAttrsToList source-repository-package package-repos;
          zipPackages = builtins.zipAttrsWith
            (k: vs:
              if k == "cabalProject" then vs
              else builtins.zipAttrsWith (_: last) vs
            );

          zippedPackages = zipPackages packages;

      in {
        inputMap =
          if builtins.hasAttr "inputMap" zippedPackages
          then zippedPackages.inputMap
          else {};
        cabalProject = if builtins.hasAttr "cabalProject" zippedPackages
          then zippedPackages.cabalProject
          else "";
      };

    # inline-cabal-project
    # :: Path (base directory)
    # -> Path (project file)
    # -> String
    inline-cabal-project = dir: file:
      let path = dir + "/${file}";
          content =
            if hasPrefix "http://" file || hasPrefix "https://" file
            then builtins.fetchurl file
            else builtins.readFile path;
          lines = splitString "\n" content;

          parseLine = line:
            let splitLine = builtins.match "([ ]*)import: (.*)" line;
                subproject = builtins.elemAt splitLine 1;
            in if splitLine != null
              then inline-cabal-project dir subproject
              else line;
          parsed-lines = forEach lines parseLine;

      in concatStringsSep "\n" parsed-lines;

in {
  inherit source-repository-package source-repository-packages inline-cabal-project;
}

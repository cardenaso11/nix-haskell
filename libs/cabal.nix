{ pkgs }:

with pkgs.lib;

let decode = import ./source-repository-package.nix;

    # source-repository-package
    # :: String -> (Path || Thunk || { src :: Path || Thunk; condition :: String || Null } || { outPath :: Path; ... })
    # -> { inputMap."Path" :: AttrSet; cabalProject :: String }
    #
    # Example:
    #
    #   source-repository-package "reflex-dom"
    #     { src = ./dep/reflex-dom; subdir = "reflex-dom"; condition = "!arch(javascript)"; }
    #   => { inputMap."/nix/store/<hash>-reflex-dom" = { name = "reflex-dom"; outPath = <path>; rev = "HEAD"; };
    #        cabalProject = ''
    #          if !arch(javascript)
    #            source-repository-package
    #              type: git
    #              location: /nix/store/<hash>-reflex-dom
    #              tag: HEAD
    #              subdir: reflex-dom
    #        '';
    #      }
    source-repository-package = name: package-repo:
      let inherit (decode package-repo) hasOutPath src condition subdirs;
          resolved =
            if hasOutPath
            then package-repo
            else { inherit name; outPath = builtins.path { path = src; inherit name; }; };
          subdirLine = optionalString (subdirs != []) "subdir: ${concatStringsSep " " subdirs}";
          # Same string as before, but with its context intact, so that a
          # derivation embedding this stanza in a cabal.project registers a
          # reference to the source it names, which is what keeps that source
          # alive in the store. `input` is only ever used as an
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
              ${subdirLine}
          ''
          else ''
            if ${condition}
              source-repository-package
                type: git
                location: ${location}
                tag: HEAD
                ${subdirLine}
          '';
      };

    # source-repository-packages
    # :: AttrSet (String -> Path || ...) -> { inputMap :: AttrSet; cabalProject :: [String] }
    #
    # Example:
    #
    #   source-repository-packages { reflex = ./dep/reflex; reflex-dom = ./dep/reflex-dom; }
    #   => { inputMap = { "/nix/store/<hash>-reflex" = { ... }; "/nix/store/<hash>-reflex-dom" = { ... }; };
    #        cabalProject = [ <reflex stanza> <reflex-dom stanza> ];
    #      }
    source-repository-packages = package-repos:
      let packages = mapAttrsToList source-repository-package package-repos;

          # Stanzas accumulate into a list; the inputMap entries merge into
          # one attrset.
          mergeField = k: vs:
            if k == "cabalProject"
            then vs
            else builtins.zipAttrsWith (_: last) vs;

          zippedPackages = builtins.zipAttrsWith mergeField packages;

      in {
        inputMap = zippedPackages.inputMap or {};
        cabalProject = zippedPackages.cabalProject or "";
      };

    # inline-cabal-project
    # :: Path (base directory)
    # -> Path (project file)
    # -> String
    #
    # Example:
    #
    #   inline-cabal-project ./project "cabal.project"   # contains "import: extra.project"
    #   => the text of cabal.project, with the import line replaced by the
    #      text of extra.project (recursively; https urls are fetched)
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

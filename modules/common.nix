{ config, lib, pkgs, ... }:

with lib;

{

  options = {

    system = mkOption {
      type = types.str;
      default = builtins.currentSystem;
      defaultText = ''
        builtins.currentSystem
      '';
    };

    name = mkOption {
      type = types.nullOr types.str;
      default = if isPath config.src
        then baseNameOf config.src
        else getName config.src;
      description = ''
        Optional name for better error messages.
      '';
    };

    src = mkOption {
      type = types.either types.path types.package;
      example = "./.";
    };

    clean-src = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Filter `src` through the `.gitignore` it carries before copying it into
        the store, so build artifacts (`dist-newstyle`, `result`, `.git`) do not
        become part of every derivation that names the project source, and a
        rebuild does not rehash them. Only applies when `src` is a path; a
        derivation is used as-is.
      '';
    };

    clean-src-patterns = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra gitignore-syntax patterns applied on top of the tree's own
        `.gitignore` when `clean-src` is enabled. Useful for artifacts that only
        a nested `.gitignore` lists, since those patterns are not read.
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
        then import ../libs/clean-source.nix { inherit pkgs; } {
               src = config.src;
               name = config.name;
               patterns = config.clean-src-patterns;
             }
        else config.src;
      defaultText = literalMD ''
      ```
        import ../libs/clean-source.nix { inherit pkgs; } {
          src = config.src;
          name = config.name;
          patterns = config.clean-src-patterns;
        }
      ```
      '';
      description = ''
        `src` with build artifacts filtered out, or `src` itself when
        `clean-src` is disabled. This is what the project is actually built
        from.
      '';
    };

    compiler-nix-name = mkOption {
      type = types.str;
      description = ''
        The name of the ghc compiler to use.
      '';
      example = "ghc884";
      default = "ghc914";
      defaultText = "ghc914";
    };

    cabalProject = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = ''
        Content of the `cabal.project` file. Passed through to haskell.nix.
      '';
    };

    cabalProjectLocal = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = ''
        Content of the `cabal.project.local` file. Passed through to haskell.nix.
      '';
    };

    cabalProjectFreeze = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = ''
        Content of the `cabal.project.freeze` file. Passed through to haskell.nix.
      '';
    };

    cabalProjectFileName = mkOption {
      type = types.str;
      default = "cabal.project";
      description = ''
        Name of the cabal project file. Passed through to haskell.nix.
      '';
    };

    extraCabalProject = mkOption {
      type = types.listOf types.lines;
      default = [];
      description = ''
        Lines to append to `cabal.project`.
      '';
    };

    extraSrcFiles = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        ExtraSrcFiles to include in the project builds
      '';
    };

    inputMap = mkOption {
      type = types.attrs;
      default = {};
      apply = x: config.source-repository-packages-driver.inputMap // x;
      description = ''
        Specifies the contents of urls in the cabal.project file.
        The `.rev` attribute is checked against the `tag` for `source-repository-packages`.
      '';
      example = literalMD ''
        ```
          inputMap = {
            "{url}/{rev/ref}" = dep_src;
            "https://github.com/obsidiansystems/obelisk-oauth.git/a528c0542e9c30851e7c4542468a053fa5e482ef" = thunkSource ./dep/{thunk};
          };
        ```
      '';
    };

    sha256map = mkOption {
      type = types.nullOr (types.attrsOf (types.either types.str (types.attrsOf types.str)));
      default = null;
      description = ''
        An alternative to adding `--sha256` comments into the cabal.project file.
      '';
      example = literalMD ''
        ```
          sha256map = {
            "url"."rev/ref" = "hash"
            "https://github.com/jgm/pandoc-citeproc"."0.17" = "0dxx8cp2xndpw3jwiawch2dkrkp15mil7pyx7dvd810pwc22pm2q";
            "https://github.com/obsidiansystems/obelisk-oauth.git"."a528c0542e9c30851e7c4542468a053fa5e482ef" = lib.fakeHash;
          };
        ```
      '';
    };

    modules = mkOption {
      readOnly = true;
      type = types.listOf (
        types.submodule {
          imports = [
            ({...}@project_args:
              let options_modules = [
                    (config.inputs."haskell-nix" + "/modules/cabal.nix")
                    (config.inputs."haskell-nix" + "/modules/component-options.nix")
                    (config.inputs."haskell-nix" + "/modules/hackage.nix")
                    (config.inputs."haskell-nix" + "/modules/package-options.nix")
                    (config.inputs."haskell-nix" + "/modules/plan.nix")
                  ];
                  #configs_modules = [
                  #  (config.inputs."haskell-nix" + "/modules/configuration-nix.nix")
                  #];
                  module_args = project_args // {
                    pkgs = import (config.inputs."haskell-nix" + "/lib/system-pkgs.nix") config."haskell-nix".nixpkgs;
                    pkgconfPkgs = import (config.inputs."haskell-nix" + "/lib/pkgconf-nixpkgs-map.nix") config."haskell-nix".nixpkgs;
                    haskellLib = config."haskell-nix".lib;
                  };
                  options = zipAttrsWith (name: vals: last vals) (map (module: (import module module_args).options) options_modules);
                  #configs = zipAttrsWith (name: vals: last vals) (map (module: (import module module_args).config) configs_modules);
              in {
                inherit options;
                #config = configs;
              }
            )
          ];
        }
      );
      default = [];
      apply = x:
          lib.optional (config.extraSrcFiles != {}) {
              packages."${config.name}".components = config.extraSrcFiles;
            }
          ++ x
          ++ config.overrides or []
          ++ config.hackage-driver.package-overlays or []
          ++ config.source-repository-packages-driver.overrides or [];
      description = ''
        `modules` option definitions (readonly). To actually change them use `overrides`.
      '';
    };

    overrides = mkOption {
      type = types.listOf types.unspecified;
      default = [];
      description = ''
        `modules` overrides.
      '';
    };



    shell = mkOption {
      type = types.submodule {
        imports = [
          ({...}@project_args:
            let modules = [
                  (config.inputs."haskell-nix" + "/modules/shell.nix")
                ];
                module_args = project_args // {
                  pkgs = import (config.inputs."haskell-nix" + "/lib/system-pkgs.nix") config."haskell-nix".nixpkgs;
                  pkgconfPkgs = import (config.inputs."haskell-nix" + "/lib/pkgconf-nixpkgs-map.nix") config."haskell-nix".nixpkgs;
                  haskellLib = config."haskell-nix".lib;
                };
                options = zipAttrsWith (name: vals: last vals) (map (module: ((import module { projectConfig = config."haskell-nix".options; }) module_args).options) modules);
            in {
              options = recursiveUpdate options {
                # Override types.str → types.lines so multiple modules can merge shellHook.
                shellHook = mkOption {
                  type = types.lines;
                  default = options.shellHook.default or "";
                  description = options.shellHook.description or "Shell hook to run when entering the shell.";
                };
                crossPlatforms = (options.crossPlatforms or {}) // {
                  defaultText = literalMD ''
                    ```
                    ps: []
                    ```
                  '';
                };
                packages = mkOption {
                  type = types.unspecified;
                  default = ps: builtins.filter (p: (p.isLocal or false) && !(config.source-repository-packages ? ${p.identifier.name or ""})) (builtins.attrValues ps);
                  apply = x: ps: concatMap (p: if (! builtins.isString p) then [ p ] else let v = ps.${p} or null; in optional (v != null) v) (x ps);
                  description = ''
                    Package selection function. It takes a list of Haskell packages and returns a subset of these packages with all of their dependencies included in `ghc-pkg list`.
                    It can take either a `package` or name (`string`) of a package which availability can depend on the platform.
                  '';
                  example = literalMD ''
                    ```
                    ps: with ps; [
                      common
                      frontend
                      "backend" # Provided by name so that it is only included when it's among `ps`
                    ]
                    ```
                  '';
                };
              };
            }
          )
        ];
      };
    };



    index-state = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Hackage index-state.
      '';
      example = "2019-10-10T00:00:00Z";
    };

    extra-hackage-tarballs = mkOption {
      type = types.nullOr types.attrs;
      default = {};
      apply = x: (if config.hackage-overlays == [] then {} else config.hackage-driver.extra-hackage-tarballs) // x;
      description = ''
        Additional Hackage tarball indices to pass to haskell.nix. Automatically includes tarballs from `hackage-overlays` when set.
      '';
    };

    extra-hackages = mkOption {
      type = types.nullOr (types.listOf types.unspecified);
      default = [];
      apply = x: (if config.hackage-overlays == [] then [] else config.hackage-driver.extra-hackages) ++ x;
      description = ''
        Additional Hackage package sets for the cabal solver. Automatically includes packages from `hackage-overlays` when set.
      '';
    };

    pkg-def-extras = mkOption {
      type = types.nullOr (types.listOf types.unspecified);
      default = [];
      description = ''
        Extra package definition functions to pass to haskell.nix.
      '';
    };



    src-driver = mkOption {
      type = types.path;
      default = import ../libs/src-driver.nix {
        inherit pkgs;
        src = config.src-cleaned;
        extraCabalProject =
          ( if config.source-repository-packages-driver.cabalProject != null && config.source-repository-packages-driver.cabalProject != ""
            then config.source-repository-packages-driver.cabalProject
            else []
          )
          ++ config.extraCabalProject or [];
      };
      defaultText = literalMD ''
      ```
        import ../libs/src-driver.nix {
          inherit pkgs;
          src = config.src-cleaned;
          extraCabalProject =
               [config.source-repository-packages-driver.cabalProject]
            ++ config.extraCabalProject or [];
        };
      ```
      '';
      readOnly = true;
    };



    source-repository-packages-driver = mkOption {
      type = types.attrs;
      default = (import ../libs/cabal.nix { inherit pkgs; }).source-repository-packages config.source-repository-packages;
      defaultText = literalMD ''
      ```
      (import ../libs/cabal.nix { inherit pkgs; }).source-repository-packages config.source-repository-packages;
      ```
      '';
      readOnly = true;
    };

    source-repository-packages = mkOption {
      type = types.attrsOf (types.either types.path types.attrs);
      default = {};
      description = ''
        Local packages to add to the project as `source-repository-package`
        stanzas. A source is anything `inputs` accepts, so a packed thunk
        directory can be given as-is and is resolved to the source it pins.
      '';
      example = literalMD ''
        ```
        {
          obelisk-frontend = deps.obelisk + "/lib/frontend";
          obelisk-backend = {
            src = deps.obelisk + "/lib/backend";
            condition = "!arch(javascript)";
          };

          reflex-dom = deps.reflex-dom + "/reflex-dom";
          reflex-dom-core = deps.reflex-dom + "/reflex-dom-core";
          reflex = deps.reflex;
        }
        ```
      '';
    };



    hackage-driver = mkOption {
      type = types.attrs;
      default = import ../libs/hackage-driver.nix {
        pkgs = config."haskell-nix".nixpkgs;
        compiler-nix-name = config.compiler-nix-name;
        modules = config.hackage-overlays;
      };
      defaultText = literalMD ''
      ```
        import ../libs/hackage-driver.nix {
          pkgs = config."haskell-nix".nixpkgs;
          compiler-nix-name = config.compiler-nix-name;
          modules = config.hackage-overlays;
        };
      ```
      '';
      readOnly = true;
      description = ''
        Internal driver that generates a fake Hackage index from `hackage-overlays`.
      '';
    };

    hackage-overlays = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = ''
        Overlays for hackage, to pass to the cabal solver.

        This will automatically pull and put the defined packages into a "fake" hackage. This allows the cabal solver see packages that can't be conventially added to cabal.project.
        A good example of this is obelisk-generated-static.

        This is a purely helper-code for the nix-side of haskell.nix
      '';
      example = literalMD ''
        ```
        [
          {
            name = "android-activity";
            version = "0.1.1";
            src = pkgs.fetchFromGitHub {
              owner = "obsidiansystems";
              repo = "android-activity";
              rev = "2bc40f6f907b27c66428284ee435b86cad38cff8";
              sha256 = "sha256-AIpbe0JZX68lsQB9mpvR7xAIct/vwQAARVHAK0iChV4=";
            };
          }
        ]
        ```
      '';
    };

  };



  config = {

    shell = {

      crossPlatforms = mkDefault (_: []);

      tools = {
        cabal = mkDefault "latest";
        hoogle = mkDefault {
          version = "5.0.19.0";
          cabalProjectLocal = ''
            if impl(ghc == 9.14.*)
              allow-newer:
                  *:base
                , *:template-haskell
                , *:ghc-experimental
                , *:ghc-internal
                , *:containers
              constraints:
                  base < 4.23
                , template-haskell < 2.25
                , ghc-experimental < 9.1500
                , ghc-internal < 9.1500
          '';
        };
      };

    };

  };

}

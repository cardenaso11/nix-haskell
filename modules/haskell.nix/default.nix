# The haskell.nix driver.
#
# Everything haskell.nix-specific lives under the `haskell-nix` namespace:
# project options are set through `haskell-nix.options`, driver conveniences
# (`overrides`, `extraCabalProject`, `extraSrcFiles`) sit directly under
# `haskell-nix`, and `haskell-nix.translation` records how every common
# option maps onto haskell.nix. The translation table is what actually
# populates `haskell-nix.options`, and its keys are checked against the
# common options by tests/.

{ config, lib, pkgs, system, ... }:

with lib;

let cfg = config."haskell-nix";

    # Wrapper scripts for the cross platforms selected by
    # `shell.crossPlatforms`, built from this driver's own cross projects.
    crossWrappers =
      let mkWrappers = import ../../libs/cross-wrappers.nix { inherit pkgs lib; };
      in concatMap (p: mkWrappers p.shell.ghc)
           (config.shell.crossPlatforms cfg.project.projectCross);

    # One haskell.nix module per field of the common `packages` option. The
    # inner `config` is haskell.nix's own, so `? name` skips packages absent
    # from the project, as the common option promises.
    packagesField = field: translate:
      let isSet = value: all id
            [ (value != null)
              (value != [])
              (value != {})
            ];
          relevant = filterAttrs (_: tweaks: isSet tweaks.${field}) config.packages;
      in mkIf (relevant != {}) {
        modules = [
          ({ config, ... }: {
            packages = mapAttrs (_: translate)
              (filterAttrs (name: _: config.packages ? ${name}) relevant);
          })
        ];
      };

    # Per-package fields translated verbatim into a haskell.nix module; the
    # names are haskell.nix's own. Only `src` needs special handling and has
    # an explicit entry in the table.
    packagesFieldNames = [
      "flags" "patches" "ghcOptions"
      "configureFlags" "setupBuildFlags" "setupHaddockFlags"
      "doCheck" "doHaddock" "doCoverage" "doHoogle" "doHyperlinkSource" "doQuickjump"
      "dontStrip" "enableDeadCodeElimination"
      "enableLibraryProfiling" "enableProfiling" "profilingDetail"
      "enableShared" "enableStatic"
      "enableSeparateDataOutput" "enableLibraryForGhci"
    ];

    packagesTranslation = listToAttrs (map (field: nameValuePair "packages.*.${field}" {
      set = packagesField field (t: { ${field} = t.${field}; });
      via = "a `packages.<name>.${field}` module";
    }) packagesFieldNames);

in {

  options = {

    "haskell-nix" = {

      input = mkOption {
        type = types.raw;
        default = import config.inputs."haskell-nix" { inherit system; };
        defaultText = literalMD ''
          ```
          import config.inputs."haskell-nix" { inherit system; }
          ```
        '';
      };

      nixpkgsSource = mkOption {
        type = types.raw;
        default = config."haskell-nix".input.sources.nixpkgs-unstable;
        defaultText = literalMD ''
          ```
          config."haskell-nix".input.sources.nixpkgs-unstable
          ```
        '';
      };

      nixpkgsArgs = mkOption {
        type = types.raw;
        default = config."haskell-nix".input.nixpkgsArgs;
        defaultText = literalMD ''
          ```
          config."haskell-nix".input.nixpkgsArgs
          ```
        '';
      };

      nixpkgs = mkOption {
        type = types.raw;
        default = import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs);
        defaultText = literalMD ''
          ```
          import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs)
          ```
        '';
      };

      haskell-nix = mkOption {
        type = types.raw;
        default = config."haskell-nix".nixpkgs.haskell-nix;
        defaultText = literalMD ''
          ```
          config."haskell-nix".nixpkgs.haskell-nix
          ```
        '';
      };

      lib = mkOption {
        type = types.raw;
        default = config."haskell-nix".haskell-nix.haskellLib;
        defaultText = literalMD ''
          ```
          config."haskell-nix".haskell-nix.haskellLib
          ```
        '';
      };



      overrides = mkOption {
        type = types.listOf types.unspecified;
        default = [];
        description = ''
          haskell.nix `modules` to add to the project. The escape hatch for
          anything the common options do not cover. Lists are concatenated
          when composed (not replaced).
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
          ExtraSrcFiles to include in the project builds.
        '';
      };



      src-driver = mkOption {
        type = types.path;
        readOnly = true;
        internal = true;
        default = import ../../libs/src-driver.nix {
          inherit pkgs;
          src = config.src-cleaned;
          extraCabalProject =
            ( if config."haskell-nix".source-repository-packages-driver.cabalProject != null && config."haskell-nix".source-repository-packages-driver.cabalProject != ""
              then config."haskell-nix".source-repository-packages-driver.cabalProject
              else []
            )
            ++ config."haskell-nix".extraCabalProject;
        };
        description = ''
          `src-cleaned` with `extraCabalProject` lines and generated
          `source-repository-package` stanzas appended to `cabal.project`.
        '';
      };

      source-repository-packages-driver = mkOption {
        type = types.attrs;
        readOnly = true;
        internal = true;
        default = (import ../../libs/cabal.nix { inherit pkgs; }).source-repository-packages config.source-repository-packages;
        description = ''
          `source-repository-package` stanzas and the `inputMap` entries
          pinning their sources, generated from `source-repository-packages`.
        '';
      };

      hackage-driver = mkOption {
        type = types.attrs;
        readOnly = true;
        internal = true;
        default = import ../../libs/hackage-driver.nix {
          pkgs = config."haskell-nix".nixpkgs;
          compiler-nix-name = config."haskell-nix".options.compiler-nix-name;
          modules = config.hackage-overlays;
        };
        description = ''
          A generated hackage index that makes `hackage-overlays` visible to
          the cabal solver.
        '';
      };



      translation = mkOption {
        type = import ../../libs/translation.nix { inherit lib; };
        readOnly = true;
        internal = true;
        description = ''
          How each common option maps onto haskell.nix. The `set` payloads
          populate `haskell-nix.options`; the keys are compared against the
          common options by the totality check.
        '';
        default = {

          system.via = "the haskell.nix checkout is imported for `system`";

          name.set = mkIf (config.name != null) { name = config.name; };
          name.via = "project `name`";

          src.set = { src = mkForce cfg.src-driver; };
          src.via = "the src-driver derivation built from `src-cleaned`";

          clean-src.via = "consumed by `src-cleaned`, which feeds the src-driver";
          clean-src-patterns.via = "consumed by `src-cleaned`, which feeds the src-driver";

          compiler-nix-name.set = { compiler-nix-name = config.compiler-nix-name; };
          compiler-nix-name.via = "project `compiler-nix-name`";

          source-repository-packages.set = { inputMap = cfg.source-repository-packages-driver.inputMap; };
          source-repository-packages.via = "`source-repository-package` stanzas appended by the src-driver, with `inputMap` pinning their sources";

          hackage-overlays.set = mkIf (config.hackage-overlays != []) {
            extra-hackage-tarballs = cfg.hackage-driver.extra-hackage-tarballs;
            extra-hackages = cfg.hackage-driver.extra-hackages;
            modules = cfg.hackage-driver.package-overlays;
          };
          hackage-overlays.via = "the hackage-driver's generated hackage index, package sets and src overrides";

          ghcOptions.set = mkIf (config.ghcOptions != []) {
            modules = [ { ghcOptions = config.ghcOptions; } ];
          };
          ghcOptions.via = "a project-wide `ghcOptions` module";

          "packages.*.src" = {
            set = packagesField "src" (t: { src = mkForce t.src; });
            via = "a `packages.<name>.src` module";
          };

          "shell.packages".set = {
            shell.packages =
              if config.shell.packages != null
              then config.shell.packages
              else ps: builtins.filter
                (p: (p.isLocal or false) && !(config.source-repository-packages ? ${p.identifier.name or ""}))
                (builtins.attrValues ps);
          };
          "shell.packages".via = "`shell.packages`, defaulting to the project's local packages";

          "shell.tools".set = { shell.tools = config.shell.tools; };
          "shell.tools".via = "`shell.tools`";

          "shell.buildInputs".set = { shell.buildInputs = config.shell.buildInputs ++ crossWrappers; };
          "shell.buildInputs".via = "`shell.buildInputs`, with cross wrapper scripts appended";

          "shell.nativeBuildInputs".set = { shell.nativeBuildInputs = config.shell.nativeBuildInputs; };
          "shell.nativeBuildInputs".via = "`shell.nativeBuildInputs`";

          "shell.shellHook".via = "appended to the project shell with overrideAttrs, deferring its evaluation";
          "shell.withHoogle".via = "applied to the project shell with overrideAttrs, deferring its evaluation";

          "shell.crossPlatforms".set = { shell.crossPlatforms = config.shell.crossPlatforms; };
          "shell.crossPlatforms".via = "`shell.crossPlatforms` (haskell.nix cross projects are keyed by the same `pkgsCross` names)";

          inputs.via = "`inputs.haskell-nix` supplies the haskell.nix checkout the driver imports";
          optimizations.via = "writes the common `ghcOptions` option";
          isGhcjs.via = "adds nodejs to the common `shell.buildInputs`";
          isWasm.via = "adds nodejs to the common `shell.buildInputs`";

        } // packagesTranslation;
      };



      options = mkOption {
        default = {};
        type = types.submodule {
          imports = [
            # The documentation generator walks this submodule without the
            # translation's definitions; defaults of haskell.nix options
            # derive from src, so it needs one here. The translation's
            # mkForce wins in the real evaluation.
            { config.src = mkDefault config.src-cleaned; }
            ({...}@project_args:
              let modules = [
                    (config.inputs."haskell-nix" + "/modules/cabal-project.nix")
                    (config.inputs."haskell-nix" + "/modules/project-common.nix")
                    (config.inputs."haskell-nix" + "/modules/project.nix")
                  ];
                  module_args = project_args // { pkgs = config."haskell-nix".nixpkgs; haskellLib = config."haskell-nix".lib; };
                  options = zipAttrsWith (name: vals: last vals) (map (module: (import module module_args).options) modules);
              in {
                options = recursiveUpdate options {
                  evalPackages.defaultText = literalMD ''
                    ```
                    if pkgs.pkgsBuildBuild.stdenv.system == config.evalSystem
                    then pkgs.pkgsBuildBuild
                    else
                      import pkgs.path {
                        system = config.evalSystem;
                        overlays = pkgs.overlays;
                      };
                    ```
                  '';
                  inputMap.description = ''
                    Specifies the contents of urls in the cabal.project file.
                    The `.rev` attribute is checked against the `tag` for `source-repository-packages`.

                    For `revision` blocks the `inputMap.<url>` will be used and
                    they `.tar.gz` for the `packages` used will also be looked up
                    in the `inputMap`.
                  '';
                };
              }
            )
          ];
        };
      };

      project = mkOption {
        default =
          let p = config.haskell-nix.haskell-nix.project config.haskell-nix.options;
          in p // {
            shell = p.shell.overrideAttrs (old: {
              shellHook = old.shellHook + config.shell.shellHook;
              withHoogle = old.withHoogle or config.shell.withHoogle;
            });
          };
        defaultText = literalMD ''
          ```
          config.haskell-nix.haskell-nix.project config.haskell-nix.options
          ```
        '';
        type = types.raw;
      };

    };

  };

  config = mkMerge [

    {
      haskell-nix.options = mkMerge (
        [
          { hsPkgs = mkDefault null; }
          { modules = cfg.overrides; }
          (mkIf (cfg.extraSrcFiles != {}) {
            modules = [ { packages.${config.name}.components = cfg.extraSrcFiles; } ];
          })
        ]
        ++ map (t: mkIf (t.set != null) t.set) (attrValues cfg.translation)
      );
    }

    {
      # The hoogle version haskell.nix can build against ghc 9.14.
      haskell-nix.options.shell.tools.hoogle = mkDefault {
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
    }

  ];

}

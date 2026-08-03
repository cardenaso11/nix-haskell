# The nixpkgs driver.
#
# Builds the project with the Haskell infrastructure of nixpkgs
# (haskell.packages.<compiler>, callCabal2nix, haskell.lib) from the package
# set of `inputs.nixpkgs`. Everything nixpkgs-specific lives under the
# `nixpkgs` namespace: driver knobs under `nixpkgs.options`, the result under
# `nixpkgs.project`, and `nixpkgs.translation` records how every common
# option maps onto nixpkgs. haskell.nix's pure parsers (cabal-project-parser,
# host-map) are reused for project interpretation; its toolchain is only
# involved when `nixpkgs.options.use-plan` opts into cabal-exact discovery.

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.nixpkgs;

    # The common options, re-declared under this driver's namespace and
    # seeded from the top-level values: setting e.g.
    # `nixpkgs.packages.foo.flags` overrides the common value for this
    # driver only. The driver reads all common configuration through the
    # mirror.
    common = import ../../libs/driver-common.nix {
      inherit lib pkgs cfg;
      topConfig = config;
    };

in {

  options.nixpkgs = common.options // {

      pkgs = mkOption {
        type = types.raw;
        default = pkgs;
        defaultText = literalMD ''
          ```
          import config.inputs.nixpkgs { inherit (config) system; }
          ```
        '';
        description = ''
          The nixpkgs package set the driver builds with.
        '';
      };

      compiler = mkOption {
        type = types.str;
        default = cfg.compiler-nix-name;
        defaultText = literalMD ''
          ```
          config.nixpkgs.compiler-nix-name
          ```
        '';
        description = ''
          Name of the `haskell.packages` set to use. An escape hatch for when
          `compiler-nix-name` has no nixpkgs equivalent.
        '';
      };

      haskellPackages = mkOption {
        type = types.raw;
        default =
          config.nixpkgs.pkgs.haskell.packages.${config.nixpkgs.compiler}
            or (throw ("nix-haskell (nixpkgs driver): pkgs.haskell.packages has no \"${config.nixpkgs.compiler}\""
              + " (available: ${concatStringsSep ", " (filter (hasPrefix "ghc") (attrNames config.nixpkgs.pkgs.haskell.packages))});"
              + " set nixpkgs.compiler or nixpkgs.haskellPackages"));
        defaultText = literalMD ''
          ```
          config.nixpkgs.pkgs.haskell.packages.''${config.nixpkgs.compiler}
          ```
        '';
        description = ''
          The base Haskell package set, before the project's packages and
          overrides are layered on top.
        '';
      };



      options = mkOption {
        default = {};
        description = ''
          nixpkgs-specific project options.
        '';
        type = types.submodule {
          options = {

            overrides = mkOption {
              type = types.listOf types.raw;
              default = [];
              description = ''
                Overlays over the Haskell package set (`self: super: { ... }`),
                applied after everything the driver generates. The escape
                hatch for anything the common options do not cover.
              '';
              example = literalMD ''
                ```
                [ (self: super: { my-dep = pkgs.haskell.lib.dontCheck super.my-dep; }) ]
                ```
              '';
            };

            packages = mkOption {
              type = types.nullOr (types.attrsOf (types.submodule {
                options.subdir = mkOption {
                  type = types.str;
                  default = ".";
                  description = ''
                    Directory of the package within the project source.
                  '';
                };
              }));
              default = null;
              description = ''
                Explicit map of the project's local packages, keyed by cabal
                package name. Overrides discovery entirely.
              '';
              example = literalMD ''
                ```
                {
                  common.subdir = "common";
                  frontend.subdir = "frontend";
                }
                ```
              '';
            };

            use-plan = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Take the project's structure (local packages, their
                directories, source-repository-packages) from the cabal plan
                of the haskell.nix driver instead of the root of the source.
                This is cabal's own reading of cabal.project, so globs,
                optional-packages and conditionals are all exact, at the cost
                of evaluating the haskell.nix toolchain (import from
                derivation). The packages are still built from nixpkgs.
              '';
            };

            extra-package-defaults = mkOption {
              default = {};
              description = ''
                Defaults applied to packages rooted outside the project
                source (source-repository-packages, hackage-overlays).
                Without a solver their version bounds routinely need
                loosening.
              '';
              type = types.submodule {
                options = {
                  jailbreak = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Lift version bounds (`haskell.lib.doJailbreak`).";
                  };
                  check = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Run their test suites.";
                  };
                  haddock = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Build their documentation.";
                  };
                };
              };
            };

            tool-packages = mkOption {
              type = types.attrsOf types.package;
              default = {};
              description = ''
                Overrides for `shell.tools` resolution, keyed by tool name.
                By default a tool is looked up as `pkgs.<name>` and then in
                the Haskell package set; version requests are ignored, since
                nixpkgs carries a single version.
              '';
              example = literalMD ''
                ```
                { haskell-language-server = pkgs.haskell-language-server; }
                ```
              '';
            };

            shellFor-args = mkOption {
              type = types.attrs;
              default = {};
              description = ''
                Extra arguments passed to `shellFor` verbatim
                (`extraDependencies`, `doBenchmark`, ...).
              '';
            };

          };
        };
      };



      translation = mkOption {
        type = import ../../libs/translation.nix { inherit lib; };
        readOnly = true;
        internal = true;
        description = ''
          How each common option maps onto nixpkgs. The keys are compared
          against the common options by the totality check.
        '';
        default = {

          system.via = "the package set is instantiated for `system`";

          name.via = "names the development shell";

          src.via = "local packages are discovered in `src-cleaned` and built with callCabal2nix";

          clean-src.via = "consumed by `src-cleaned`, which local packages are built from";
          clean-src-patterns.via = "consumed by `src-cleaned`, which local packages are built from";

          compiler-nix-name.via = "selects `pkgs.haskell.packages.<name>` (overridable with `nixpkgs.compiler`)";

          cabalProject.via = "replaces the project file as the text whose source-repository-package stanzas are honored";
          cabalProjectLocal.via = "appended to the project text before stanza parsing";
          cabalProjectFileName.via = "the project file read for stanzas";
          extraCabalProject.via = "appended to the project text before stanza parsing";
          inputMap.via = "stanza urls (or url/rev) resolve through it before fetching";
          sha256map.via = "hashes for fetching stanza sources, like `--sha256` comments";

          source-repository-packages.via = "callCabal2nix on the resolved sources, one entry per `subdir`; `condition` is evaluated against the target platform (haskell.nix's host-map); stanzas in cabal.project are parsed by haskell.nix's parser and fetched";

          hackage-overlays.via = "callCabal2nix entries in the package set";

          ghcOptions.via = "`--ghc-option` configure flags on the project's packages";

          "packages.*.flags".via = "`--flag` cabal2nix options for generated packages, enableCabalFlag/disableCabalFlag otherwise";
          "packages.*.patches".via = "haskell.lib appendPatches";
          "packages.*.ghcOptions".via = "`--ghc-option` configure flags";
          "packages.*.configureFlags".via = "haskell.lib appendConfigureFlags";
          "packages.*.setupBuildFlags".via = "mkDerivation `buildFlags`";
          "packages.*.setupHaddockFlags".via = "mkDerivation `haddockFlags`";
          "packages.*.doCheck".via = "mkDerivation `doCheck`";
          "packages.*.doHaddock".via = "mkDerivation `doHaddock`";
          "packages.*.doCoverage".via = "mkDerivation `doCoverage`";
          "packages.*.doHoogle".via = "mkDerivation `doHoogle`";
          "packages.*.doHyperlinkSource".via = "mkDerivation `hyperlinkSource`";
          "packages.*.doQuickjump".via = "mkDerivation `doHaddockQuickjump`";
          "packages.*.dontStrip".via = "mkDerivation `dontStrip`";
          "packages.*.enableDeadCodeElimination".via = "mkDerivation `enableDeadCodeElimination`";
          "packages.*.enableLibraryProfiling".via = "mkDerivation `enableLibraryProfiling`";
          "packages.*.enableProfiling".via = "mkDerivation `enableLibraryProfiling` and `enableExecutableProfiling`";
          "packages.*.profilingDetail".via = "mkDerivation `profilingDetail`";
          "packages.*.enableShared".via = "mkDerivation `enableSharedLibraries`";
          "packages.*.enableStatic".via = "mkDerivation `enableStaticLibraries`";
          "packages.*.enableSeparateDataOutput".via = "mkDerivation `enableSeparateDataOutput`";
          "packages.*.enableLibraryForGhci".via = "mkDerivation `enableLibraryForGhci`";
          "packages.*.src".via = "haskell.lib overrideSrc";

          "shell.packages".via = "shellFor `packages`, selecting from the project's packages and source-repository-packages";
          "shell.tools".via = "resolved by name in `pkgs` and the Haskell package set (version requests are ignored; see `nixpkgs.options.tool-packages`)";
          "shell.buildInputs".via = "shellFor `buildInputs`";
          "shell.nativeBuildInputs".via = "shellFor `nativeBuildInputs`, after the resolved tools";
          "shell.shellHook".via = "shellFor `shellHook`";
          "shell.withHoogle".via = "shellFor `withHoogle`";
          "shell.crossPlatforms".via = "cross wrapper scripts from the selected `pkgsCross` compilers; full cross package sets under `project.projectCross`";

          inputs.via = "`inputs.nixpkgs` supplies the package set; `inputs.haskell-nix` supplies the reused parsers";
          optimizations.via = "writes the common `ghcOptions` option";
          isGhcjs.via = "adds nodejs to the common `shell.buildInputs`";
          isWasm.via = "adds nodejs to the common `shell.buildInputs`";

        } // listToAttrs (map
          (field: nameValuePair "packages.*.${field}" { via = "mkDerivation `${field}`"; })
          ( [ "hardeningDisable" ]
            ++ concatMap (phase: [ "pre${phase}" "post${phase}" ])
                 [ "Unpack" "Patch" "Configure" "Build" "Check" "Haddock" "Install" ] ));
      };



      project = mkOption {
        type = types.raw;
        default = import ../../libs/nixpkgs/driver.nix {
          pkgs = config.nixpkgs.pkgs;
          haskellPackages = config.nixpkgs.haskellPackages;
          inherit lib config;
        };
        defaultText = literalMD ''
          ```
          import <nix-haskell>/libs/nixpkgs/driver.nix {
            pkgs = config.nixpkgs.pkgs;
            haskellPackages = config.nixpkgs.haskellPackages;
            inherit lib config;
          }
          ```
        '';
        description = ''
          The built project: `packages` (the project's own packages),
          `haskellPackages` (the full extended set), `shell`, `projectCross`
          (per `pkgsCross` platform) and `ghcWithPackages`.
        '';
      };

  };

  config = mkMerge [

    {
      nixpkgs = common.seeds;
    }

    {
      nixpkgs = common.config;
    }

  ];

}

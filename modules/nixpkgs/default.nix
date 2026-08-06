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

{ config, options, lib, pkgs, ... }:

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
      topOptions = options;
    };
    mkDriverDefault = common.mkDriverDefault;

    # The `compiler` option resolved per platform.
    compilers = import ../../libs/compiler.nix { inherit lib; } {
      compiler = cfg.compiler;
      system = cfg.system;
    };
    compiler = compilers.native;

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

      pkgsCross = mkOption {
        type = types.attrsOf types.raw;
        default = mapAttrs
          (platform: _: import ../../libs/nixpkgs/cross-pkgs.nix {
            inherit lib platform;
            nixpkgs = config.inputs.nixpkgs;
            system = cfg.system;
            compiler = compilers.resolve platform;
            defaults = cfg.options.cross-package-defaults;
          })
          (filterAttrs (_: spec: spec.toolchain.package != null) cfg.compiler.platforms);
        defaultText = literalMD ''
          ```
          <nix-haskell>/libs/nixpkgs/cross-pkgs.nix
          ```
          for every `compiler.platforms` entry carrying a `toolchain`: a
          package set for that platform whose whole toolchain is the
          compiler's own, built non-static so that the compiler's shared
          libraries can be used. A platform without an entry gets none, and
          the driver falls back to `pkgs.pkgsCross.<platform>`.
        '';
        description = ''
          Cross package sets for `project.projectCross`, keyed by
          `pkgs.pkgsCross` platform name. An entry replaces the package set
          the driver would otherwise take from `pkgs.pkgsCross`, which is
          what a compiler bringing its own toolchain needs, since that
          toolchain has to become the whole set's.
        '';
      };

      haskellPackages = mkOption {
        type = types.raw;
        default = import ../../libs/nixpkgs/haskell-packages.nix {
          inherit lib compiler;
          pkgs = config.nixpkgs.pkgs;
        };
        defaultText = literalMD ''
          ```
          config.nixpkgs.pkgs.haskell.packages.''${config.nixpkgs.compiler.name}
          ```
          A compiler package replaces that set's `ghc` instead, preferring
          the set of its own major.minor.patch version.
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

            cross-package-defaults = mkOption {
              default = {};
              description = ''
                Defaults applied to every package of a cross set the driver
                builds itself, the one a compiler bringing its own toolchain
                needs (`nixpkgs.pkgsCross`). They sit under the project's own
                `packages.<name>` settings, which the driver layers on after.
                Tests and benchmarks are not among them: a cross set has no
                way to run what it builds, so they are always off there.
              '';
              type = types.submodule {
                options = {
                  jailbreak = mkOption {
                    type = types.bool;
                    default = true;
                    description = ''
                      Lift version bounds (`haskell.lib.doJailbreak`). A cross
                      set has no solver to satisfy them with.
                    '';
                  };
                  haddock = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Build documentation.";
                  };
                  profiling = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Build profiling libraries.";
                  };
                };
              };
            };

            tool-packages = mkOption {
              type = types.attrsOf types.package;
              default = {};
              defaultText = literalMD ''
                ```
                { cabal = config.nixpkgs.pkgs.cabal-install; }
                ```
              '';
              description = ''
                Overrides for `shell.tools` resolution, keyed by tool name.
                A tool is looked up here first, then as `pkgs.<name>`, then in
                the Haskell package set; version requests are ignored, since
                nixpkgs carries a single version. `cabal` is here because the
                tool's name is not the name of the package carrying it; an
                entry of the project's own replaces it.
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
          clean-src-ignore-files.via = "consumed by `src-cleaned`, which local packages are built from";
          clean-src-patterns.via = "consumed by `src-cleaned`, which local packages are built from";

          "compiler.name".via = "selects `pkgs.haskell.packages.<name>`; with a package, names the set whose `ghc` it replaces";
          "compiler.package".via = "replaces the `ghc` of the base package set";
          "compiler.version".via = "spliced onto the compiler as `ghc.version`; the package set the project is built against is the one of that major.minor.patch";
          "compiler.targetPrefix".via = "spliced onto the compiler as `ghc.targetPrefix`, which names every tool the builders call";
          "compiler.enableShared".via = "a cross package set is built non-static, with shared and not static libraries";
          "compiler.toolchain".via = "becomes a cross package set's own toolchain, a setup dependency of every package, and every package's configure flags";
          "compiler.haskell-nix".via = "read by the haskell.nix driver only";
          "compiler.nixpkgs".via = "`haskellCompilerName` is spliced onto the compiler, naming the package database directories of everything built and cabal2nix's `--compiler`; `enableExternalInterpreter` is passed to every package in a cross set";
          "compiler.platforms".via = "each entry gives `projectCross.<platform>` its own compiler, and with a toolchain its own package set (`nixpkgs.pkgsCross`)";

          "platforms.*.packages".via = "merged over `packages` for `projectCross.<platform>`, before cabal2nix is told a package's flags";
          "packages.*.components".via = "nothing to do: for a ghcjs target the generic builder already copies every `dist/build/*/*.jsexe` into `$out/bin`";

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
          wasm-opt.via = "nothing the driver builds; read by `wasm-optimize`";
          closure.via = "nothing the driver builds; read by `js-optimize`";
          wasm-optimize.via = "applied by the project to a wasm binary the driver has already built";
          wasm-jsffi.via = "applied by the project to a wasm binary the driver has already built, with the compiler `nixpkgs.cross-compiler` names";
          js-optimize.via = "applied by the project to a jsexe the driver has already built";

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

      cross-compiler = mkOption {
        type = types.functionTo types.package;
        default = platform: cfg.project.projectCross.${platform}.haskellPackages.ghc;
        defaultText = literalMD ''
          ```
          platform: config.nixpkgs.project.projectCross.<platform>.haskellPackages.ghc
          ```
        '';
        description = ''
          The compiler this driver builds a cross target with, by
          `pkgs.pkgsCross` name. Both drivers answer to the same name, so a
          step that needs the compiler an artifact was built with, as
          `wasm-jsffi` does, asks for it the same way whichever driver built
          the artifact:

          ```
          config.<driver>.cross-compiler "wasi32"
          ```
        '';
      };

      cross-exe = mkOption {
        type = types.functionTo types.package;
        default = { platform, package, exe }:
          cfg.project.projectCross.${platform}.packages.${package};
        defaultText = literalMD ''
          ```
          { platform, package, exe }:
            config.nixpkgs.project.projectCross.<platform>.packages.<package>
          ```
        '';
        description = ''
          What this driver builds an executable into, for one cross target. Both
          drivers answer to the same name, and what they answer with carries the
          executable at `bin/<exe>`, with a wasm target's binary at
          `bin/<exe>.wasm` and a javascript target's linked directory at
          `bin/<exe>.jsexe`. It is what `bundles` optimizes.

          This driver builds one derivation per package, so the executable's own
          name says nothing about where to look; it is taken for the sake of the
          one interface both drivers answer to.
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

    {
      # This driver's own compiler, for a project that names none: no stackage
      # snapshot covers ghc 9.14 yet, so the nixpkgs ghc914 package set has
      # neither consistent bounds nor cached builds. A compiler package names
      # itself through its version, so the default would stand in front of
      # that rather than behind it.
      nixpkgs.compiler.name =
        mkIf (cfg.compiler.package == null) (mkDriverDefault "ghc912");
    }

    {
      # The one shell tool whose name is not the name of the package carrying
      # it. A definition rather than the option's `default`, so that a project
      # naming other tools keeps this entry.
      nixpkgs.options.tool-packages.cabal = mkOptionDefault cfg.pkgs.cabal-install;
    }

  ];

}

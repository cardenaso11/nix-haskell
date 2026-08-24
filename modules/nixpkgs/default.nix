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
with (import ../../libs/prelude { inherit lib; });

let cfg = config.nixpkgs;

    # The common options, re-declared under this driver's namespace and
    # seeded from the top-level values: setting e.g.
    # `nixpkgs.packages.foo.flags` overrides the common value for this
    # driver only. The driver reads all common configuration through the
    # mirror.
    common = import ../../libs/driver-common.nix {
      inherit lib pkgs cfg;
      driver = "nixpkgs";
      topConfig = config;
      topOptions = options;
    };
    # `compiler` is the native entry, which names the project-wide compiler.
    compilers = common.compilers;
    compiler = compilers.native;

    platformsWithToolchain =
      filterAttrs (_: entry: entry.hasToolchain) compilers.platforms;

    crossSetFor = platform: import ../../libs/nixpkgs/cross-pkgs.nix {
      inherit lib platform;
      nixpkgs = config.inputs.nixpkgs;
      system = cfg.system;
      compiler = compilers.resolve platform;
      defaults = cfg.options.cross-package-defaults;
    };

    packageFields = import ../../libs/package-fields.nix { inherit lib; };

    flagField = default: description: mkOption {
      type = types.bool;
      inherit default description;
    };

    translations = import ../../libs/translation.nix { inherit lib; };

in {

  options.nixpkgs = common.options
    // common.interface {

      compiler-version = {
        fallback = cfg.haskellPackages.ghc.version;
        defaultText = literalMD ''
          the version `compiler.version` states, or the one carried by the
          compiler the driver resolves: the package a project brought, or the
          `ghc` of the package set it selected
        '';
      };

      cross-compiler = {
        default = platform: cfg.project.projectCross.${platform}.haskellPackages.ghc;
        defaultText = fenced-code ''platform: config.nixpkgs.project.projectCross.<platform>.haskellPackages.ghc'';
      };

      cross-exe = {
        default = { platform, package, exe }:
          cfg.project.projectCross.${platform}.packages.${package};
        defaultText = fenced-code ''
          { platform, package, exe }:
            config.nixpkgs.project.projectCross.<platform>.packages.<package>
        '';
        extraDescription = ''

          This driver builds one derivation per package, so the executable's
          own name does not affect the lookup. The function takes it only to
          keep the one interface both drivers answer to.
        '';
      };

    } // {

      pkgs = mkOption {
        type = types.raw;
        default = pkgs;
        defaultText = fenced-code ''import config.inputs.nixpkgs { inherit (config) system; }'';
        description = ''
          The nixpkgs package set the driver builds with.
        '';
      };

      pkgsCross = mkOption {
        type = types.attrsOf types.raw;
        default = mapAttrs (platform: _: crossSetFor platform) platformsWithToolchain;
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
          the driver would otherwise take from `pkgs.pkgsCross`. A compiler
          bringing its own toolchain needs the replacement, since that
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
              example = fenced-code ''[ (self: super: { my-dep = pkgs.haskell.lib.dontCheck super.my-dep; }) ]'';
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
              example = fenced-code ''
                {
                  common.subdir = "common";
                  frontend.subdir = "frontend";
                }
              '';
            };

            use-plan = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Take the project's structure (local packages, their
                directories, source-repository-packages) from the cabal
                plan of the haskell.nix driver instead of the root of the
                source. The plan is cabal's own reading of cabal.project,
                so globs, optional-packages and conditionals are all exact.
                The cost is evaluating the haskell.nix toolchain (import
                from derivation). The packages are still built from
                nixpkgs.

                This turns `exact-configuration` on by default. The bounds
                of the packages a plan brings in are the other half of
                reading a cabal.project on a driver with no solver.
              '';
            };

            exact-configuration = mkOption {
              type = types.bool;
              default = cfg.options.use-plan;
              defaultText = literalMD "`nixpkgs.options.use-plan`";
              description = ''
                Tell Cabal every direct dependency, by the id its package
                database records, and every flag the package declares. Cabal
                then resolves nothing itself and reads no version bound.

                With no bounds read, a package builds against a compiler
                released after its cabal file was written. This includes a
                bound inside a conditional stanza, which `jailbreak` cannot
                reach.

                The haskell.nix driver configures every package this way.
                That is why `allow-newer` in a cabal.project takes effect in
                that driver and not in this one.

                A flag the project states in `packages.<name>.flags` still
                decides. The generated assignments go first, and Cabal takes
                the last assignment of a flag.

                The default follows `use-plan` unless the project sets this
                option. A plan read from a cabal.project brings in the
                packages that the file's `allow-newer` was written for, and
                this driver has no other way past their bounds. Set the
                option explicitly to break the link, in either direction.
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
                  jailbreak = flagField true "Lift version bounds (`haskell.lib.doJailbreak`).";
                  check = flagField false "Run the test suites of these packages.";
                  haddock = flagField false "Build the documentation of these packages.";
                };
              };
            };

            cross-package-defaults = mkOption {
              default = {};
              description = ''
                Defaults applied to every package of a cross set the driver
                builds itself (`nixpkgs.pkgsCross`), the set a compiler
                bringing its own toolchain needs. They sit under the
                project's own `packages.<name>` settings, which the driver
                layers on after. Tests and benchmarks are not among the
                fields: a cross set has no way to run what it builds, so
                they are always off there.
              '';
              type = types.submodule {
                options = {
                  jailbreak = flagField true ''
                    Lift version bounds (`haskell.lib.doJailbreak`). A cross
                    set has no solver to satisfy them with.
                  '';
                  haddock = flagField false "Build documentation.";
                  profiling = flagField false "Build profiling libraries.";
                };
              };
            };

            tool-packages = mkOption {
              type = types.attrsOf types.package;
              default = {};
              defaultText = fenced-code ''{ cabal = config.nixpkgs.pkgs.cabal-install; }'';
              description = ''
                Overrides for `shell.tools` resolution, keyed by tool name.
                A tool is looked up here first, then as `pkgs.<name>`, then
                in the Haskell package set. Version requests are ignored,
                since nixpkgs carries a single version. `cabal` is here
                because the tool's name is not the name of the package
                carrying it. An entry of the project's own replaces it.
              '';
              example = fenced-code ''{ haskell-language-server = pkgs.haskell-language-server; }'';
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



      translation = translations.declare {
        driver = "nixpkgs";
        default = {

          system.via = "the package set is instantiated for `system`";

          name.via = "names the development shell";

          src.via = "local packages are discovered in `src-cleaned` and built with callCabal2nix";

          "compiler.name".via = "selects `pkgs.haskell.packages.<name>`; with a package, names the set whose `ghc` it replaces";
          "compiler.package".via = "replaces the `ghc` of the base package set";
          "compiler.version".via = "spliced onto the compiler as `ghc.version`; the package set the project is built against is the one of that major.minor.patch";
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

          "packages.*.src".via = "haskell.lib overrideSrc";

          "shell.packages".via = "shellFor `packages`, selecting from the project's packages and source-repository-packages";
          "shell.tools".via = "resolved by name in `pkgs` and the Haskell package set (version requests are ignored; see `nixpkgs.options.tool-packages`)";
          "shell.buildInputs".via = "shellFor `buildInputs`";
          "shell.nativeBuildInputs".via = "shellFor `nativeBuildInputs`, after the resolved tools";
          "shell.shellHook".via = "shellFor `shellHook`";
          "shell.withHoogle".via = "shellFor `withHoogle`";
          "shell.crossPlatforms".via = "cross wrapper scripts from the selected `pkgsCross` compilers; full cross package sets under `project.projectCross`";

          inputs.via = "`inputs.nixpkgs` supplies the package set; `inputs.haskell-nix` supplies the reused parsers";

        } // packageFields.vias
          // translations.common-vias {
            namespace = "nixpkgs";
            src-consumer = "local packages are built from";
          };
      };



      project = mkOption {
        type = types.raw;
        default = import ../../libs/nixpkgs/driver.nix {
          pkgs = config.nixpkgs.pkgs;
          haskellPackages = config.nixpkgs.haskellPackages;
          inherit lib config;
        };
        defaultText = fenced-code ''
          import <nix-haskell>/libs/nixpkgs/driver.nix {
            pkgs = config.nixpkgs.pkgs;
            haskellPackages = config.nixpkgs.haskellPackages;
            inherit lib config;
          }
        '';
        description = ''
          The built project: `packages` (the project's own packages),
          `haskellPackages` (the full extended set), `shell`, `projectCross`
          (per `pkgsCross` platform) and `ghcWithPackages`.
        '';
      };

  };

  config = mkMerge (common.mirror-config {
    namespace = "nixpkgs";
    # No stackage snapshot covers ghc 9.14 yet, so the nixpkgs ghc914
    # package set has neither consistent bounds nor cached builds.
    defaultCompiler = "ghc912";
  } ++ [

    {
      # The one shell tool whose name is not the name of the package carrying
      # it. A definition rather than the option's `default`, so that a project
      # naming other tools keeps this entry.
      nixpkgs.options.tool-packages.cabal = mkOptionDefault cfg.pkgs.cabal-install;
    }

  ]);

}

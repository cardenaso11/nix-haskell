# The haskell.nix driver.
#
# Everything haskell.nix-specific lives under the `haskell-nix` namespace:
# project options are set through `haskell-nix.options`, driver conveniences
# (`overrides`, `extraCabalProject`, `extraSrcFiles`) sit directly under
# `haskell-nix`, and `haskell-nix.translation` records how every common
# option maps onto haskell.nix. The translation table populates
# `haskell-nix.options`, and every common option needs an entry in it, or
# evaluation fails.

{ config, options, lib, pkgs, system, ... }:

with lib;
with (import ../../libs/prelude { inherit lib; });

let cfg = config."haskell-nix";

    # The common options, re-declared under this driver's namespace and
    # seeded from the top-level values: setting e.g.
    # `haskell-nix.packages.foo.flags` overrides the common value for this
    # driver only. The driver reads all common configuration through the
    # mirror.
    common = import ../../libs/driver-common.nix {
      inherit lib pkgs cfg;
      driver = "haskell.nix";
      topConfig = config;
      topOptions = options;
    };

    packageFields = import ../../libs/package-fields.nix { inherit lib; };

    translations = import ../../libs/translation.nix { inherit lib; };

    # `compiler` is the native entry, which names the project-wide compiler.
    compilers = common.compilers;
    compiler = compilers.native;

    # The generated source-repository-package stanzas, as cabal.project lines
    # to append; empty when the project declares none.
    srpStanzaLines =
      let stanzas = cfg.source-repository-packages-driver.cabalProject;
      in if stanzas != null && stanzas != ""
         then stanzas
         else [];

    selectionNeeded = cfg.compiler.platforms != {} || compiler.package != null;

    prefix = import ../../libs/message-prefix.nix { driver = "haskell.nix"; };

    missingCompiler = key:
      throw (prefix "haskell-nix.compiler has no \"${key}\"");

    foreignPlatformName = target:
      throw (prefix ("the compiler named \"${target.name}\""
        + " differs from the project-wide \"${compiler.name}\"; this driver's cross projects"
        + " share one name, so a platform of its own needs a `package`"));

    # `cachedDeps` carries the boot packages' exact-configuration flags.
    # haskell.nix's own compilers have it; its fallback for those that do not
    # interpolates the compiler itself instead of the deps, leaving every
    # boot package unresolved, so it is attached here.
    compilerFor = target: key: p:
      if target.annotated != null
      then cfg.lib.makeCompilerDeps target.annotated
      else if target.name == compiler.name
      then p.haskell-nix.compiler.${key} or (missingCompiler key)
      else foreignPlatformName target;

    selectCompiler = p:
      let target = compilers.resolve (compilers.targetKey p.stdenv.targetPlatform);
          key = p.haskell-nix.resolve-compiler-name compiler.name;
      in { ${key} = compilerFor target key p; };

    # haskell.nix builds shell tools in their own projects, keyed only by
    # `compiler-nix-name` (default selection: `haskell-nix.compiler.<name>`).
    # A compiler package's own name is generally absent there, so tools are
    # pinned to the driver's compiler of the same version instead. Priority
    # 1099: above haskell.nix's own injection (1100), below user definitions.
    # A tool spec is a version string, a module, or a list of modules.
    toolModules = spec:
      if isString spec then [ { version = spec; } ]
      else if isList spec then spec
      else [ spec ];
    withToolCompiler = spec:
      if compiler.package == null then spec
      else toolModules spec ++ [ { compiler-nix-name = mkOverride 1099 compiler.stockName; } ];

    # Wrapper scripts for the cross platforms selected by
    # `shell.crossPlatforms`, built from this driver's own cross projects.
    crossWrappers =
      let mkWrappers = import ../../libs/cross-wrappers.nix { inherit pkgs lib; };
      in concatMap (p: mkWrappers p.shell.ghc)
           (cfg.shell.crossPlatforms cfg.project.projectCross);

    # One haskell.nix module per field of the common `packages` option. The
    # inner `config` is haskell.nix's own, so `? name` skips packages absent
    # from the project.
    packagesField = field: translate:
      let relevant = filterAttrs (_: tweaks: is-set tweaks.${field}) cfg.packages;
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
    packagesFieldNames = packageFields.names;

    packagesTranslation = listToAttrs (map (field: nameValuePair "packages.*.${field}" {
      set = packagesField field (t: { ${field} = t.${field}; });
      via = "a `packages.<name>.${field}` module";
    }) packagesFieldNames);

    # The executables a project named, gathered from the project-wide entries
    # and from every target's, so one named for a single target is installed
    # too. Naming an executable that has no `.jsexe` costs nothing: the module
    # looks for the directory before copying it.
    namedExes =
      let exesIn = packages:
            mapAttrs (_: tweaks: attrNames tweaks.components.exes)
              (filterAttrs (_: tweaks: tweaks.components.exes != {}) packages);
          trees = [ cfg.packages ] ++ map (target: target.packages) (attrValues cfg.platforms);
      in zipAttrsWith (_: named: unique (concatLists named)) (map exesIn trees);

in {

  options."haskell-nix" = common.options
    // common.interface {

      compiler-version = {
        # haskell.nix keys its compilers by exact version, and resolves the
        # name a project writes to one of them.
        fallback = cfg.haskell-nix.compiler.${cfg.haskell-nix.resolve-compiler-name compiler.name}.version;
        defaultText = literalMD ''
          the version `compiler.version` states, or the one carried by the
          compiler the driver resolves: the package a project brought, or the
          one haskell.nix has under that name
        '';
      };

      cross-compiler = {
        default = platform: cfg.project.projectCross.${platform}.pkg-set.config.ghc.package;
        defaultText = fenced-code ''
          platform:
            config."haskell-nix".project.projectCross.<platform>.pkg-set.config.ghc.package
        '';
      };

      cross-exe = {
        default = { platform, package, exe }:
          cfg.project.projectCross.${platform}.hsPkgs.${package}.components.exes.${exe};
        defaultText = fenced-code ''
          { platform, package, exe }:
            config."haskell-nix".project.projectCross.<platform>
              .hsPkgs.<package>.components.exes.<exe>
        '';
      };

    } // {

      input = mkOption {
        type = types.raw;
        default = import config.inputs."haskell-nix" { inherit system; };
        defaultText = fenced-code ''import config.inputs."haskell-nix" { inherit system; }'';
        description = ''
          The haskell.nix checkout this driver builds with, imported for
          `system`. The driver takes everything else out of it: the nixpkgs
          it pins, the overlay that builds a project, and the helpers for
          selecting components.
        '';
      };

      nixpkgsSource = mkOption {
        type = types.raw;
        default = config."haskell-nix".input.sources.nixpkgs-unstable;
        defaultText = fenced-code ''config."haskell-nix".input.sources.nixpkgs-unstable'';
        description = ''
          The nixpkgs this driver builds from: the one haskell.nix pins, not
          the project's `inputs.nixpkgs`. haskell.nix's overlays and its
          compilers are written against that revision. The nixpkgs driver
          follows the project's pin instead.
        '';
      };

      nixpkgsArgs = mkOption {
        type = types.raw;
        default = config."haskell-nix".input.nixpkgsArgs;
        defaultText = fenced-code ''config."haskell-nix".input.nixpkgsArgs'';
        description = ''
          The arguments that nixpkgs is imported with: haskell.nix's own
          overlays, which put `haskell-nix` into the package set, and the
          configuration its compilers are built under.
        '';
      };

      nixpkgs = mkOption {
        type = types.raw;
        default = import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs);
        defaultText = fenced-code ''import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs)'';
        description = ''
          The package set the driver builds with, and the one every native
          tool in its shell comes from.
        '';
      };

      haskell-nix = mkOption {
        type = types.raw;
        default = config."haskell-nix".nixpkgs.haskell-nix;
        defaultText = fenced-code ''config."haskell-nix".nixpkgs.haskell-nix'';
        description = ''
          What the overlay adds to that package set: the compilers, the hackage
          index, and the `project` function the driver calls with
          `haskell-nix.options`.
        '';
      };

      lib = mkOption {
        type = types.raw;
        default = config."haskell-nix".haskell-nix.haskellLib;
        defaultText = fenced-code ''config."haskell-nix".haskell-nix.haskellLib'';
        description = ''
          haskell.nix's own helpers, `haskellLib`: selecting a project's local
          packages, collecting components and checks, and the compiler
          plumbing a bespoke compiler needs.
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

      extraSrcFiles = mkOption {
        type = types.attrs;
        default = {};
        description = ''
          Files from the project source to add to component builds, in
          haskell.nix's `extraSrcFiles` shape: `library.extraSrcFiles`,
          `exes.<name>.extraSrcFiles`, and so on.
        '';
      };



      src-driver = mkOption {
        type = types.path;
        readOnly = true;
        internal = true;
        default = import ../../libs/src-driver.nix {
          inherit pkgs;
          src = cfg.src-cleaned;
          extraCabalProject = srpStanzaLines ++ cfg.extraCabalProject;
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
        default = (import ../../libs/cabal.nix { inherit pkgs; }).source-repository-packages cfg.source-repository-packages;
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
          modules = cfg.hackage-overlays;
        };
        description = ''
          A generated hackage index that makes `hackage-overlays` visible to
          the cabal solver.
        '';
      };



      translation = translations.declare {
        driver = "haskell.nix";
        extra = "The `set` payloads populate `haskell-nix.options`. ";
        default = {

          system.via = "the haskell.nix checkout is imported for `system`";

          name.set = mkIf (cfg.name != null) { name = cfg.name; };
          name.via = "project `name`";

          src.set = { src = mkForce cfg.src-driver; };
          src.via = "the src-driver derivation built from `src-cleaned`";

          "compiler.name".set =
            { compiler-nix-name = compiler.name; }
            // optionalAttrs selectionNeeded {
              # Keyed by the name haskell.nix resolves compiler-nix-name to,
              # so the (compilerSelection pkgs).${name} lookups always hit
              # this selection. Cross projects share the one name, so
              # per-platform entries dispatch on the selection's target
              # platform. An entry that only renames the compiler has
              # nothing to dispatch to.
              compilerSelection = selectCompiler;
            };
          "compiler.name".via = "project `compiler-nix-name` (the compiler above `platforms`); packages are pinned under it through `compilerSelection`, dispatched on the target platform";

          "compiler.toolchain".set = mkIf compilers.anyToolchain {
            modules = [
              (import ../../libs/haskell-nix/compiler-toolchain.nix { inherit lib compilers; })
            ];
          };
          "compiler.toolchain".via = "a module giving every package the compiler's own configure flags, on the platforms whose entry carries a toolchain";

          "compiler.package".via = "the compiler `compilerSelection` returns for its platform, carrying haskell.nix's `cachedDeps`";
          "compiler.version".via = "spliced onto the compiler as `ghc.version`; the compiler the shell tools are built with is the driver's own of that version";
          "compiler.enableShared".via = "spliced onto the compiler as `ghc.enableShared`, which decides every component's `shared:`";
          "compiler.haskell-nix".set = mkIf compilers.anyExtraNonReinstallablePkgs {
            modules = [
              (import ../../libs/haskell-nix/non-reinstallable.nix {
                inherit lib compilers;
                haskell-nix-src = config.inputs."haskell-nix";
              })
            ];
          };
          "compiler.haskell-nix".via = "`libDir` is spliced onto the compiler, where the package database and `settings` are looked for; `extraNonReinstallablePkgs` is appended to `nonReinstallablePkgs` by a module, on the platforms whose entry names any";
          "compiler.nixpkgs".via = "read by the nixpkgs driver only";
          "compiler.platforms".via = "resolved per target platform by `compilerSelection` and by the toolchain module";

          cabalProject.set = mkIf (cfg.cabalProject != null) {
            # the project file (carrying the src-driver's generated stanzas)
            # is ignored when cabalProject is set, so they move into it
            cabalProject = concatStringsSep "\n" (
              [ cfg.cabalProject ]
              ++ srpStanzaLines
              ++ cfg.extraCabalProject
            );
          };
          cabalProject.via = "project `cabalProject`, with the generated source-repository-package stanzas and `extraCabalProject` appended";

          cabalProjectLocal.set = mkIf (cfg.cabalProjectLocal != null) {
            cabalProjectLocal = cfg.cabalProjectLocal;
          };
          cabalProjectLocal.via = "project `cabalProjectLocal`";

          cabalProjectFileName.set = { cabalProjectFileName = cfg.cabalProjectFileName; };
          cabalProjectFileName.via = "project `cabalProjectFileName`";

          extraCabalProject.via = "appended to cabal.project by the src-driver, or to `cabalProject` when that is set";

          inputMap.set = mkIf (cfg.inputMap != {}) { inputMap = cfg.inputMap; };
          inputMap.via = "project `inputMap`, merged with the generated source-repository-package entries";

          sha256map.set = mkIf (cfg.sha256map != null) { sha256map = cfg.sha256map; };
          sha256map.via = "project `sha256map`";

          source-repository-packages.set = { inputMap = cfg.source-repository-packages-driver.inputMap; };
          source-repository-packages.via = "`source-repository-package` stanzas appended by the src-driver, with `inputMap` pinning their sources";

          hackage-overlays.set = mkIf (cfg.hackage-overlays != []) {
            extra-hackage-tarballs = cfg.hackage-driver.extra-hackage-tarballs;
            extra-hackages = cfg.hackage-driver.extra-hackages;
            modules = cfg.hackage-driver.package-overlays;
          };
          hackage-overlays.via = "the hackage-driver's generated hackage index, package sets and src overrides";

          ghcOptions.set = mkIf (cfg.ghcOptions != []) {
            modules = [ { ghcOptions = cfg.ghcOptions; } ];
          };
          ghcOptions.via = "a project-wide `ghcOptions` module";

          "packages.*.src" = {
            set = packagesField "src" (t: { src = mkForce t.src; });
            via = "a `packages.<name>.src` module";
          };

          "platforms.*.packages".set = mkIf (cfg.platforms != {}) {
            modules = [
              (import ../../libs/haskell-nix/platform-packages.nix {
                inherit lib;
                platforms = cfg.platforms;
                fields = packagesFieldNames;
              })
            ];
          };
          "platforms.*.packages".via = "a `packages.<name>` module applied in the project whose target is that platform";

          "packages.*.components".set = mkIf (namedExes != {}) {
            modules = [
              (import ../../libs/haskell-nix/install-jsexe.nix {
                inherit lib;
                exes = namedExes;
              })
            ];
          };
          "packages.*.components".via = "an `<exe>.jsexe` install for every executable named, in the project whose target is javascript";

          "shell.packages".set = {
            shell.packages = import ../../libs/shell-packages-selection.nix {
              packages = cfg.shell.packages;
              inherit (cfg) source-repository-packages;
            };
          };
          "shell.packages".via = "`shell.packages`, defaulting to the project's local packages";

          "shell.tools".set = { shell.tools = mapAttrs (_: withToolCompiler) cfg.shell.tools; };
          "shell.tools".via = "`shell.tools`; with a package compiler, tools are pinned to the stock compiler matching its version";

          "shell.buildInputs".set = { shell.buildInputs = cfg.shell.buildInputs ++ crossWrappers; };
          "shell.buildInputs".via = "`shell.buildInputs`, with cross wrapper scripts appended";

          "shell.nativeBuildInputs".set = { shell.nativeBuildInputs = cfg.shell.nativeBuildInputs; };
          "shell.nativeBuildInputs".via = "`shell.nativeBuildInputs`";

          "shell.shellHook".via = "appended to the project shell with overrideAttrs, deferring its evaluation";
          "shell.withHoogle".via = "applied to the project shell with overrideAttrs, deferring its evaluation";

          "shell.crossPlatforms".set = { shell.crossPlatforms = cfg.shell.crossPlatforms; };
          "shell.crossPlatforms".via = "`shell.crossPlatforms` (haskell.nix cross projects are keyed by the same `pkgsCross` names)";

          inputs.via = "`inputs.haskell-nix` supplies the haskell.nix checkout the driver imports";

        } // packagesTranslation
          // translations.common-vias {
            namespace = "haskell-nix";
            src-consumer = "feeds the src-driver";
          };
      };



      options = mkOption {
        default = {};
        description = ''
          haskell.nix project options, passed to haskell.nix's `project`
          function as given. Any option of haskell.nix's own project modules
          can be set here (`index-state`, `cabalProjectFreeze`,
          `extra-hackages`, `pkg-def-extras`, `shell.exactDeps`, ...). The
          driver fills many of them from the common options through its
          `translation` table.
        '';
        type = types.submodule {
          imports = [
            # The documentation generator walks this submodule without the
            # translation's definitions. Defaults of haskell.nix options
            # derive from src, so the walk needs one here. The translation's
            # mkForce wins in the real evaluation.
            { config.src = mkDefault cfg.src-cleaned; }
            ({...}@projectArgs:
              let sources = [
                    (config.inputs."haskell-nix" + "/modules/cabal-project.nix")
                    (config.inputs."haskell-nix" + "/modules/project-common.nix")
                    (config.inputs."haskell-nix" + "/modules/project.nix")
                  ];

                  moduleArgs = projectArgs // {
                    pkgs = config."haskell-nix".nixpkgs;
                    haskellLib = config."haskell-nix".lib;
                  };

                  upstreamOptions = zipAttrsWith (name: vals: last vals)
                    (map (module: (import module moduleArgs).options) sources);

                  docPatches = {
                    evalPackages.defaultText = fenced-code ''
                      if pkgs.pkgsBuildBuild.stdenv.system == config.evalSystem
                      then pkgs.pkgsBuildBuild
                      else
                        import pkgs.path {
                          system = config.evalSystem;
                          overlays = pkgs.overlays;
                        };
                    '';
                    inputMap.description = ''
                      Specifies the contents of urls in the cabal.project file.
                      The `.rev` attribute is checked against the `tag` for
                      `source-repository-packages`.

                      For `revision` blocks, `inputMap.<url>` is used, and the
                      `.tar.gz` files of the `packages` used are also looked up
                      in the `inputMap`.
                    '';
                  };

              in {
                options = recursiveUpdate upstreamOptions docPatches;
              }
            )
          ];
        };
      };

      project = mkOption {
        default =
          let p = config.haskell-nix.haskell-nix.project config.haskell-nix.options;
              shellWithHooks = p.shell.overrideAttrs (old: {
                shellHook = old.shellHook + cfg.shell.shellHook;
                withHoogle = old.withHoogle or cfg.shell.withHoogle;
              });
          in p // { shell = shellWithHooks; };
        defaultText = fenced-code ''config.haskell-nix.haskell-nix.project config.haskell-nix.options'';
        description = ''
          The built project as haskell.nix returns it: `hsPkgs`, `shell`,
          `projectCross` per cross platform, `plan-nix`, and the rest. The
          shell is haskell.nix's own, with the common `shell.shellHook`
          appended and `shell.withHoogle` applied. Both go through
          `overrideAttrs`, so neither is evaluated unless the shell is.
        '';
        type = types.raw;
      };

  };

  config = mkMerge (common.mirror-config {
    namespace = "haskell-nix";
    defaultCompiler = "ghc914";
  } ++ [

    {
      haskell-nix.options = mkMerge (
        [
          { hsPkgs = mkDefault null; }
          { modules = cfg.overrides; }
          (mkIf (cfg.extraSrcFiles != {}) {
            modules = [ { packages.${cfg.name}.components = cfg.extraSrcFiles; } ];
          })
        ]
        ++ map (t: mkIf (t.set != null) t.set) (attrValues cfg.translation)
      );
    }

    {
      # The hoogle version haskell.nix can build against ghc 9.14. This
      # definition lands past `shell.tools`, so the tool-compiler pin is
      # re-applied here.
      haskell-nix.options.shell.tools.hoogle = mkDefault (withToolCompiler {
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
      });
    }

  ]);

}

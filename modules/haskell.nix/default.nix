# The haskell.nix driver.
#
# Everything haskell.nix-specific lives under the `haskell-nix` namespace:
# project options are set through `haskell-nix.options`, driver conveniences
# (`overrides`, `extraCabalProject`, `extraSrcFiles`) sit directly under
# `haskell-nix`, and `haskell-nix.translation` records how every common
# option maps onto haskell.nix. The translation table is what actually
# populates `haskell-nix.options`, and its keys are checked against the
# common options by tests/.

{ config, options, lib, pkgs, system, ... }:

with lib;

let cfg = config."haskell-nix";

    # The common options, re-declared under this driver's namespace and
    # seeded from the top-level values: setting e.g.
    # `haskell-nix.packages.foo.flags` overrides the common value for this
    # driver only. The driver reads all common configuration through the
    # mirror.
    common = import ../../libs/driver-common.nix {
      inherit lib pkgs cfg;
      topConfig = config;
      topOptions = options;
    };

    # The `compiler` option resolved per platform. `compiler` is the native
    # entry, which names the project-wide compiler.
    compilers = import ../../libs/compiler.nix { inherit lib; } {
      compiler = cfg.compiler;
      system = cfg.system;
    };
    compiler = compilers.native;

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
    # from the project, as the common option promises.
    packagesField = field: translate:
      let isSet = value: all id
            [ (value != null)
              (value != [])
              (value != {})
            ];
          relevant = filterAttrs (_: tweaks: isSet tweaks.${field}) cfg.packages;
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
      "hardeningDisable"
      "preUnpack" "postUnpack" "prePatch" "postPatch"
      "preConfigure" "postConfigure" "preBuild" "postBuild"
      "preCheck" "postCheck" "preHaddock" "postHaddock"
      "preInstall" "postInstall"
    ];

    packagesTranslation = listToAttrs (map (field: nameValuePair "packages.*.${field}" {
      set = packagesField field (t: { ${field} = t.${field}; });
      via = "a `packages.<name>.${field}` module";
    }) packagesFieldNames);

in {

  options."haskell-nix" = common.options // {

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
          src = cfg.src-cleaned;
          extraCabalProject =
            ( if config."haskell-nix".source-repository-packages-driver.cabalProject != null && config."haskell-nix".source-repository-packages-driver.cabalProject != ""
              then config."haskell-nix".source-repository-packages-driver.cabalProject
              else []
            )
            ++ cfg.extraCabalProject;
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

          name.set = mkIf (cfg.name != null) { name = cfg.name; };
          name.via = "project `name`";

          src.set = { src = mkForce cfg.src-driver; };
          src.via = "the src-driver derivation built from `src-cleaned`";

          clean-src.via = "consumed by `src-cleaned`, which feeds the src-driver";
          clean-src-patterns.via = "consumed by `src-cleaned`, which feeds the src-driver";

          "compiler.name".set =
            { compiler-nix-name = compiler.name; }
            // optionalAttrs (cfg.compiler.platforms != {} || compiler.package != null) {
              # keyed by the name haskell.nix resolves compiler-nix-name to,
              # so the (compilerSelection pkgs).${name} lookups always hit
              # this selection. Cross projects share the one name, so
              # per-platform entries dispatch on the selection's target
              # platform; an entry that only renames the compiler has nothing
              # to dispatch to.
              compilerSelection = p:
                let target = compilers.resolve (compilers.targetKey p.stdenv.targetPlatform);
                    key = p.haskell-nix.resolve-compiler-name compiler.name;
                in { ${key} =
                       # `cachedDeps` carries the boot packages' exact-configuration
                       # flags. haskell.nix's own compilers have it; its fallback for
                       # those that do not interpolates the compiler itself instead of
                       # the deps, leaving every boot package unresolved, so it is
                       # attached here.
                       if target.annotated != null then cfg.lib.makeCompilerDeps target.annotated
                       else if target.name == compiler.name
                       then p.haskell-nix.compiler.${key}
                         or (throw "nix-haskell (haskell.nix driver): haskell-nix.compiler has no \"${key}\"")
                       else throw ("nix-haskell (haskell.nix driver): the compiler named \"${target.name}\""
                         + " differs from the project-wide \"${compiler.name}\"; this driver's cross projects"
                         + " share one name, so a platform of its own needs a `package`");
                   };
            };
          "compiler.name".via = "project `compiler-nix-name` (the compiler above `platforms`); packages are pinned under it through `compilerSelection`, dispatched on the target platform";

          "compiler.toolchain".set = mkIf compilers.anyToolchain {
            modules = [
              (import ../../libs/haskell-nix/compiler-toolchain.nix {
                inherit lib compilers;
                haskell-nix-src = config.inputs."haskell-nix";
              })
            ];
          };
          "compiler.toolchain".via = "a module giving every package the compiler's own configure flags, on the platforms whose entry carries a toolchain";

          "compiler.package".via = "the compiler `compilerSelection` returns for its platform, carrying haskell.nix's `cachedDeps`";
          "compiler.version".via = "spliced onto the compiler as `ghc.version`; the compiler the shell tools are built with is the driver's own of that version";
          "compiler.targetPrefix".via = "spliced onto the compiler as `ghc.targetPrefix`, which names every tool the builders call";
          "compiler.enableShared".via = "spliced onto the compiler as `ghc.enableShared`, which decides every component's `shared:`";
          "compiler.haskell-nix".via = "`libDir` is spliced onto the compiler, where the package database and `settings` are looked for";
          "compiler.nixpkgs".via = "read by the nixpkgs driver only";
          "compiler.platforms".via = "resolved per target platform by `compilerSelection` and by the toolchain module";

          cabalProject.set = mkIf (cfg.cabalProject != null) {
            # the project file (carrying the src-driver's generated stanzas)
            # is ignored when cabalProject is set, so they move into it
            cabalProject = concatStringsSep "\n" (
              [ cfg.cabalProject ]
              ++ ( let stanzas = cfg.source-repository-packages-driver.cabalProject;
                   in if stanzas != null && stanzas != "" then stanzas else [] )
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

          "shell.packages".set = {
            shell.packages =
              if cfg.shell.packages != null
              then cfg.shell.packages
              else ps: builtins.filter
                (p: (p.isLocal or false) && !(cfg.source-repository-packages ? ${p.identifier.name or ""}))
                (builtins.attrValues ps);
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
            { config.src = mkDefault cfg.src-cleaned; }
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
              shellHook = old.shellHook + cfg.shell.shellHook;
              withHoogle = old.withHoogle or cfg.shell.withHoogle;
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

  config = mkMerge [

    {
      "haskell-nix" = common.seeds;
    }

    {
      "haskell-nix" = common.config;
    }

    {
      # This driver's own compiler, for a project that names none. A compiler
      # package names itself through its version, so the default would stand
      # in front of that rather than behind it.
      haskell-nix.compiler.name =
        mkIf (cfg.compiler.package == null) (common.mkDriverDefault "ghc914");
    }

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
      # The hoogle version haskell.nix can build against ghc 9.14. Defined
      # past `shell.tools`, so the package-compiler pin is re-applied here.
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

  ];

}

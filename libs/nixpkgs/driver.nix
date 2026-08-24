# The nixpkgs driver core: builds the project from a nixpkgs Haskell package
# set. Parameterized on `pkgs` and `haskellPackages` so cross instantiations
# are one re-application with `pkgs.pkgsCross.<platform>`.
#
# Project interpretation reuses haskell.nix wherever it has something:
# cabal-project-parser for source-repository-package stanzas, host-map for
# cabal's platform names, and (with `nixpkgs.options.use-plan`) the cabal
# plan of the haskell.nix driver for the definitive local package set.
#
# Example:
#
#   import ./driver.nix { inherit pkgs haskellPackages lib config; }
#   => { packages.hello = <derivation>;
#        haskellPackages = <the extended package set>;
#        hsPkgs = <alias of haskellPackages>;
#        shell = <shellFor derivation>;
#        projectCross.<platform> = <the same shape, built with pkgsCross>;
#        ghcWithPackages = <function>;
#        pkgs = <the nixpkgs used>;
#      }
{ pkgs, haskellPackages, lib, config, platform ? null }:

let compose = pkgs.haskell.lib.compose;
    cfg = config.nixpkgs;
    ocfg = cfg.options;

    # What the project asked for, with a cross platform's own customization
    # over the top. The platform's flags have to sit here rather than on a
    # built package. cabal2nix is told these flags, and a flag it does not
    # know about leaves the other platform's dependencies in place.
    packages =
      if platform == null
      then lib.seq unknownPlatforms cfg.packages
      else lib.recursiveUpdate cfg.packages (cfg.platforms.${platform}.packages or {});

    # Checked once, from the project this driver was asked for, since a name
    # that denotes no platform would otherwise simply never be looked up.
    prefix = import ../message-prefix.nix { driver = "nixpkgs"; };

    unknownPlatforms =
      let unknown = lib.subtractLists (builtins.attrNames pkgs.pkgsCross)
            (builtins.attrNames cfg.platforms);
      in if unknown == []
         then null
         else throw (prefix ("`platforms` names no such"
           + " platform: ${lib.concatStringsSep ", " unknown}"));

    # The `compiler` option resolved per platform.
    resolveCompiler = (import ../compiler.nix { inherit lib; } {
      compiler = cfg.compiler;
      system = cfg.system;
      driver = "nixpkgs";
    }).resolve;

    # The package set a cross platform is built from:
    # - its own, when the compiler there brings a toolchain that has to
    #   become the whole set's
    # - else the one nixpkgs assembles for the platform
    crossPkgs = platform: cfg.pkgsCross.${platform} or pkgs.pkgsCross.${platform};

    haskell-nix-src = config.inputs."haskell-nix";
    parser = import (haskell-nix-src + "/lib/cabal-project-parser.nix") { inherit pkgs; };
    hostMap = import (haskell-nix-src + "/lib/host-map.nix") pkgs.stdenv;
    project-file = import ./project-file.nix { inherit pkgs parser; };
    conditionHolds = import ./condition.nix { inherit lib hostMap; };
    decodeSrp = import ../source-repository-package.nix;
    packageFields = import ../package-fields.nix { inherit lib; };

    # ------------------------------------------------------------------------
    # Local packages: { <package-name> = { src; external; }; }
    # ------------------------------------------------------------------------

    # cabal's own reading of the project, taken from the haskell.nix driver's
    # plan. Packages rooted outside the project source (fetched
    # source-repository-packages) are marked external.
    planPackages =
      let proj = config."haskell-nix".project;
          projectSrc = toString config."haskell-nix".src-driver;
          locals = config."haskell-nix".lib.selectLocalPackages proj.hsPkgs;

          # `selectLocalPackages` keys by unit id and gives a package one entry
          # per component, so a project of one package arrives as
          # `reflex-todomvc-0.1.0.0-inplace` beside
          # `reflex-todomvc-0.1.0.0-inplace-reflex-todomvc`. Everything reading
          # this names a package, so the entries are keyed by the name each
          # carries and the components of one package collapse together.
          #
          # The source is still looked up under the unit id: the package set
          # answers to both, but only the unit id's entry carries a `src`.
          entry = key: pkg:
            let src = proj.pkg-set.config.packages.${key}.src;
            in lib.nameValuePair pkg.identifier.name
                 { inherit src; external = toString (src.origSrc or src) != projectSrc; };

      in lib.listToAttrs (lib.mapAttrsToList entry locals);

    # Discovered packages enter the set as { src; external; }. A package
    # the project source carries is never external.
    local = lib.mapAttrs (_: p: { inherit (p) src; external = false; });

    discovered =
      if ocfg.packages != null
      then local (project-file.discover { src = cfg.src-cleaned; explicit = ocfg.packages; })
      else if ocfg.use-plan
      then planPackages
      else local (project-file.discover { src = cfg.src-cleaned; });

    # ------------------------------------------------------------------------
    # source-repository-packages: { <package-name> = <src dir>; }
    # ------------------------------------------------------------------------

    # Skipped under use-plan: the plan already contains them.

    packageAt = project-file.packageAt;

    srpOptionPackages =
      let entry = attrName: spec:
            let inherit (decodeSrp spec) src condition subdirs;
                subdirsOrRoot =
                  if subdirs == []
                  then [ "." ]
                  else subdirs;
            in lib.optionals (condition == null || conditionHolds condition)
                 (map (packageAt src "source-repository-packages.${attrName}") subdirsOrRoot);
      in builtins.listToAttrs
           (lib.concatLists (lib.mapAttrsToList entry cfg.source-repository-packages));

    # The project text the stanzas are read from: the project file (or the
    # cabalProject option, which replaces it), cabal.project.local and the
    # extraCabalProject lines.
    projectText =
      let base =
            if cfg.cabalProject != null
            then cfg.cabalProject
            else project-file.projectFileText cfg.cabalProjectFileName cfg.src-cleaned;
      in lib.concatStringsSep "\n" (
           lib.optional (base != null) base
           ++ lib.optional (cfg.cabalProjectLocal != null) cfg.cabalProjectLocal
           ++ cfg.extraCabalProject);

    # Stanzas written in the project's own cabal.project. Sources resolve
    # through inputMap first, then fetchgit (hashes from --sha256 comments or
    # sha256map, applied by the parser), then plain fetchGit.
    srpStanzaPackages =
      let fetch = r:
            let url = builtins.unsafeDiscardStringContext r.url;
                rev = builtins.unsafeDiscardStringContext (r.rev or r.ref or "");
                byHash = pkgs.fetchgit { url = r.url; rev = r.rev or r.ref; inherit (r) sha256; };
                byGit = builtins.fetchGit
                  ({ url = r.url; }
                   // lib.optionalAttrs (r ? rev) { inherit (r) rev; }
                   // lib.optionalAttrs (r ? ref) { inherit (r) ref; });
                fetched =
                  if (r.sha256 or null) != null
                  then byHash
                  else byGit;
            in cfg.inputMap."${url}/${rev}" or (cfg.inputMap.${url} or fetched);
          entry = r:
            map (packageAt (fetch r) "source-repository-package ${r.url}") r.subdirs;
      in builtins.listToAttrs
           (lib.concatLists (map entry (project-file.sourceRepoStanzas cfg.sha256map projectText)));

    srpPackages =
      lib.optionalAttrs (!ocfg.use-plan) (srpOptionPackages // srpStanzaPackages);

    # ------------------------------------------------------------------------
    # The package set: one fixpoint extension over the base set
    # ------------------------------------------------------------------------

    # Cabal flags of generated packages go through cabal2nix, so the
    # dependency graph is computed under the right flag assignment, and
    # disabled tests and documentation are baked into the generated
    # expression. cabal2nix keeps test dependencies as required arguments
    # even with --no-check. A test dependency absent from the package set
    # still needs an explicit null override.
    cabal2nixOptions = name: external:
      let tweaks = packages.${name} or {};

          extraDefaults = ocfg.extra-package-defaults;

          disabled = field: tweaks.${field} or null == false;

          unset = field: tweaks.${field} or null == null;

          noCheck = disabled "doCheck"
            || (external && !extraDefaults.check && unset "doCheck");

          noHaddock = disabled "doHaddock"
            || (external && !extraDefaults.haddock && unset "doHaddock");

          flagOptions = lib.mapAttrsToList
            (f: enabled: "--flag=${lib.optionalString (!enabled) "-"}${f}")
            (tweaks.flags or {});

      in lib.concatStringsSep " " (
           flagOptions
           ++ lib.optional noCheck "--no-check"
           ++ lib.optional noHaddock "--no-haddock");

    # Every package source reaches the set the same way: cabal2nix over a
    # { src; external; } entry, keyed by package name.
    cabal2nixOverlay = entries: self: _:
      lib.mapAttrs
        (name: e: self.callCabal2nixWithOptions name e.src (cabal2nixOptions name e.external) {})
        entries;

    localPackagesOverlay = cabal2nixOverlay discovered;

    srpOverlay = cabal2nixOverlay
      (lib.mapAttrs (_: src: { inherit src; external = true; }) srpPackages);

    hackageOverlay = cabal2nixOverlay
      (builtins.listToAttrs
        (map (o: lib.nameValuePair o.name { inherit (o) src; external = true; })
          cfg.hackage-overlays));

    # Packages rooted outside the project source get pragmatic defaults.
    # Without a solver, their version bounds routinely need loosening.
    externalNames =
      lib.attrNames (lib.filterAttrs (_: p: p.external) discovered)
      ++ lib.attrNames srpPackages
      ++ map (o: o.name) cfg.hackage-overlays;

    extraDefaultsOverlay = _: super:
      let d = ocfg.extra-package-defaults;
      in lib.genAttrs externalNames (name: lib.pipe super.${name} (
           lib.optional d.jailbreak compose.doJailbreak
           ++ lib.optional (!d.check) compose.dontCheck
           ++ lib.optional (!d.haddock) compose.dontHaddock));

    generatedNames = lib.attrNames discovered ++ lib.attrNames srpPackages;

    # Common `packages` fields that set one argument each of the Haskell
    # mkDerivation, mapped to the name that builder knows it by, which is not
    # always the option's own.
    packagesFieldArgs = packageFields.args;

    # Overlay attribute names must never depend on package values, or the
    # fixpoint recurses. Presence (super ? name) decides the names, and
    # nulls pass through in the values.
    packageTweaksOverlay = _: super:
      let setArg = attr: value: compose.overrideCabal (drv: { ${attr} = value; });

          appendArg = attr: values: compose.overrideCabal (drv: { ${attr} = drv.${attr} or [] ++ values; });

          toggleFlag = f: enabled:
            (if enabled
             then compose.enableCabalFlag
             else compose.disableCabalFlag) f;

          patchSteps = tweaks:
            lib.optional (tweaks.patches != []) (compose.appendPatches tweaks.patches);

          # flags of generated packages were already applied through cabal2nix
          flagSteps = name: tweaks:
            lib.optionals (tweaks.flags != {} && !(lib.elem name generatedNames))
              (lib.mapAttrsToList toggleFlag tweaks.flags);

          ghcOptionSteps = tweaks:
            map (f: compose.appendConfigureFlag "--ghc-option=${f}") tweaks.ghcOptions;

          configureSteps = tweaks:
            lib.optional (tweaks.configureFlags != []) (compose.appendConfigureFlags tweaks.configureFlags);

          setupSteps = tweaks:
            lib.optional (tweaks.setupBuildFlags != []) (appendArg "buildFlags" tweaks.setupBuildFlags)
            ++ lib.optional (tweaks.setupHaddockFlags != []) (appendArg "haddockFlags" tweaks.setupHaddockFlags);

          fieldSteps = tweaks:
            lib.concatLists (lib.mapAttrsToList
              (field: attr: lib.optional (tweaks.${field} != null) (setArg attr tweaks.${field}))
              packagesFieldArgs);

          profilingStep = tweaks:
            lib.optional (tweaks.enableProfiling != null)
              (compose.overrideCabal (drv: {
                enableLibraryProfiling = tweaks.enableProfiling;
                enableExecutableProfiling = tweaks.enableProfiling;
              }));

          srcStep = tweaks:
            lib.optional (tweaks.src != null) (compose.overrideSrc { inherit (tweaks) src; });

          steps = name: tweaks:
            patchSteps tweaks
            ++ flagSteps name tweaks
            ++ ghcOptionSteps tweaks
            ++ configureSteps tweaks
            ++ setupSteps tweaks
            ++ fieldSteps tweaks
            ++ profilingStep tweaks
            ++ srcStep tweaks;

          tweak = name: tweaks:
            if super.${name} == null
            then null
            else lib.pipe super.${name} (steps name tweaks);

          # tweaks for packages absent from the set are silently ignored
          present = lib.filterAttrs (name: _: super ? ${name}) packages;

      in lib.mapAttrs tweak present;

    # Project-wide ghcOptions apply to the project's own packages. Applying
    # them to the whole set would invalidate the binary cache for the entire
    # dependency closure.
    ghcOptionsOverlay = _: super:
      lib.genAttrs (lib.attrNames discovered)
        (name: lib.pipe super.${name}
          (map (f: compose.appendConfigureFlag "--ghc-option=${f}") cfg.ghcOptions));

    # How a package is configured rather than which package it is, so it goes on
    # the set's `mkDerivation` rather than on names.
    exactConfigurationOverlay = _: super: {
      mkDerivation = args: super.mkDerivation (args // {
        preConfigure = (args.preConfigure or "") + import ./exact-configuration.nix {
          ghc = "${haskellPackages.ghc.targetPrefix}ghc";
        };
      });
    };

    projectOverlays =
      lib.optional ocfg.exact-configuration exactConfigurationOverlay
      ++ [ localPackagesOverlay srpOverlay hackageOverlay extraDefaultsOverlay packageTweaksOverlay ]
      ++ lib.optional (cfg.ghcOptions != []) ghcOptionsOverlay
      ++ ocfg.overrides;

    hp = haskellPackages.extend (lib.composeManyExtensions projectOverlays);

    # ------------------------------------------------------------------------
    # Shell
    # ------------------------------------------------------------------------

    # What `shell.packages` selects from: the project's packages plus
    # source-repository-packages, tagged the way selection functions expect.
    # Tagging with // preserves outPath, which shellFor's local-package
    # detection compares. The full package set is never offered. It contains
    # null (boot) and throwing (removed) attributes.
    selectionSet =
      lib.genAttrs generatedNames
        (name: hp.${name} // { isLocal = true; identifier = { inherit name; }; });

    selection = import ../shell-packages-selection.nix {
      packages = cfg.shell.packages;
      inherit (cfg) source-repository-packages;
    };

    # Tools are resolved by name. Version requests cannot be honored without
    # a solver and are ignored.
    resolveTool = name: _:
      let sources = [ ocfg.tool-packages pkgs hp ];
          found = lib.findFirst (set: set ? ${name}) null sources;
      in if found == null
         then throw (prefix "cannot find the shell tool \"${name}\"; set nixpkgs.options.tool-packages.\"${name}\"")
         else found.${name};

    # The wrapped cross compiler carries the dependencies of the shell
    # selection in its package database, like shellFor's environment does
    # for the native compiler. Without a hackage index in the shell, cabal
    # can only resolve against installed packages. Setup dependencies are
    # left out. They build on the native side.
    #
    # The wrapper comes from cross-ghc-env.nix rather than from the set's
    # own `ghcWithPackages`, which aims the compiler at a library directory
    # it builds from the version and so cannot wrap a relocatable bindist.
    crossGhcEnv = platform:
      let chp = projectCross.${platform}.haskellPackages;
          selected = map (p: chp.${p.identifier.name}) (selection selectionSet);
          notSelected = d: lib.all (p: (d.outPath or null) != p.outPath) selected;
          isRunDep = n:
            n == "buildDepends"
            || (lib.hasSuffix "HaskellDepends" n && n != "setupHaskellDepends");
          depsOf = p: lib.concatLists
            (lib.attrValues (lib.filterAttrs (n: _: isRunDep n) p.getCabalDeps));
      in import ./cross-ghc-env.nix { inherit pkgs lib; } {
           ghc = chp.ghc;
           packages = lib.filter (d: d != null && notSelected d) (lib.concatMap depsOf selected);
         };

    crossWrappers =
      let mkWrappers = import ../cross-wrappers.nix { inherit pkgs lib; };
          probe = (import ../cross-platform.nix { inherit lib; }).probe pkgs;
      in lib.concatMap (platform: mkWrappers (crossGhcEnv platform))
           (cfg.shell.crossPlatforms probe);

    shellArgs = {
      packages = _: selection selectionSet;
      withHoogle = cfg.shell.withHoogle;
      nativeBuildInputs =
        lib.mapAttrsToList resolveTool cfg.shell.tools
        ++ cfg.shell.nativeBuildInputs
        ++ crossWrappers;
      buildInputs = cfg.shell.buildInputs;
      shellHook = cfg.shell.shellHook;
    } // lib.optionalAttrs (cfg.name != null) { name = "${cfg.name}-shell"; }
      // ocfg.shellFor-args;

    shell = hp.shellFor shellArgs;

    # ------------------------------------------------------------------------
    # Cross
    # ------------------------------------------------------------------------

    projectCross = lib.genAttrs (builtins.attrNames pkgs.pkgsCross) (crossPlatform:
      let platformPkgs = crossPkgs crossPlatform;
      in import ./driver.nix {
        pkgs = platformPkgs;
        haskellPackages = import ./haskell-packages.nix {
          inherit lib;
          pkgs = platformPkgs;
          compiler = resolveCompiler crossPlatform;
        };
        inherit lib config;
        platform = crossPlatform;
      });

in {
  inherit pkgs shell projectCross;
  haskellPackages = hp;
  # Rough symmetry with the haskell.nix project. There is no per-component
  # tree: haskell.nix's hsPkgs.<name>.components.exes.<exe> corresponds to
  # packages.<name> here (with the executable at $out/bin/<exe>).
  hsPkgs = hp;
  packages = lib.genAttrs (lib.attrNames discovered) (name: hp.${name});
  ghcWithPackages = hp.ghcWithPackages;
}

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
{ pkgs, haskellPackages, lib, config }:

let compose = pkgs.haskell.lib.compose;
    cfg = config.nixpkgs;
    ocfg = cfg.options;

    haskell-nix-src = config.inputs."haskell-nix";
    parser = import (haskell-nix-src + "/lib/cabal-project-parser.nix") { inherit pkgs; };
    hostMap = import (haskell-nix-src + "/lib/host-map.nix") pkgs.stdenv;
    project-file = import ./project-file.nix { inherit pkgs parser; };
    conditionHolds = import ./condition.nix { inherit lib hostMap; };
    decodeSrp = import ../source-repository-package.nix;



    # ---- Local packages: { <package-name> = { src; external; }; } ----

    # cabal's own reading of the project, taken from the haskell.nix driver's
    # plan. Packages rooted outside the project source (fetched
    # source-repository-packages) are marked external.
    planPackages =
      let proj = config."haskell-nix".project;
          projectSrc = toString config."haskell-nix".src-driver;
          locals = config."haskell-nix".lib.selectLocalPackages proj.hsPkgs;
      in lib.mapAttrs
           (name: _:
             let src = proj.pkg-set.config.packages.${name}.src;
             in { inherit src; external = toString (src.origSrc or src) != projectSrc; })
           locals;

    discovered =
      if ocfg.packages != null
      then lib.mapAttrs (_: p: { inherit (p) src; external = false; })
             (project-file.discover { src = cfg.src-cleaned; explicit = ocfg.packages; })
      else if ocfg.use-plan
      then planPackages
      else lib.mapAttrs (_: p: { inherit (p) src; external = false; })
             (project-file.discover { src = cfg.src-cleaned; });



    # ---- source-repository-packages (skipped under use-plan: the plan
    # already contains them): { <package-name> = <src dir>; } ----

    srpOptionPackages =
      let entry = attrName: spec:
            let inherit (decodeSrp spec) src condition subdirs;
                pkgAt = d:
                  let dir = if d == "." then src else src + "/${d}";
                      name = project-file.packageNameIn dir;
                  in if name == null
                     then throw "nix-haskell (nixpkgs driver): no cabal package in ${toString dir} (source-repository-packages.${attrName})"
                     else lib.nameValuePair name dir;
            in lib.optionals (condition == null || conditionHolds condition)
                 (map pkgAt (if subdirs == [] then [ "." ] else subdirs));
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
            in cfg.inputMap."${url}/${rev}"
                 or (cfg.inputMap.${url}
                 or (if (r.sha256 or null) != null
                     then pkgs.fetchgit { url = r.url; rev = r.rev or r.ref; inherit (r) sha256; }
                     else builtins.fetchGit
                       ({ url = r.url; }
                        // lib.optionalAttrs (r ? rev) { inherit (r) rev; }
                        // lib.optionalAttrs (r ? ref) { inherit (r) ref; })));
          entry = r:
            let src = fetch r;
                pkgAt = d:
                  let dir = if d == "." then src else src + "/${d}";
                      name = project-file.packageNameIn dir;
                  in if name == null
                     then throw "nix-haskell (nixpkgs driver): no cabal package in ${toString dir} (source-repository-package ${r.url})"
                     else lib.nameValuePair name dir;
            in map pkgAt r.subdirs;
      in builtins.listToAttrs
           (lib.concatLists (map entry (project-file.sourceRepoStanzas cfg.sha256map projectText)));

    srpPackages =
      lib.optionalAttrs (!ocfg.use-plan) (srpOptionPackages // srpStanzaPackages);



    # ---- The package set: one fixpoint extension over the base set ----

    # Cabal flags of generated packages go through cabal2nix, so the
    # dependency graph is computed under the right flag assignment, and
    # disabled tests and documentation are baked into the generated
    # expression. Note that cabal2nix keeps test dependencies as required
    # arguments even with --no-check: a test dependency absent from the
    # package set still needs an explicit null override.
    cabal2nixOptions = name: external:
      let t = cfg.packages.${name} or {};
          d = ocfg.extra-package-defaults;
          noCheck = (t.doCheck or null) == false
            || (external && !d.check && (t.doCheck or null) == null);
          noHaddock = (t.doHaddock or null) == false
            || (external && !d.haddock && (t.doHaddock or null) == null);
      in lib.concatStringsSep " " (
           lib.mapAttrsToList
             (f: enabled: "--flag=${lib.optionalString (!enabled) "-"}${f}")
             (t.flags or {})
           ++ lib.optional noCheck "--no-check"
           ++ lib.optional noHaddock "--no-haddock");

    localPackagesOverlay = self: _:
      lib.mapAttrs
        (name: p: self.callCabal2nixWithOptions name p.src (cabal2nixOptions name p.external) {})
        discovered;

    srpOverlay = self: _:
      lib.mapAttrs
        (name: dir: self.callCabal2nixWithOptions name dir (cabal2nixOptions name true) {})
        srpPackages;

    hackageOverlay = self: _:
      builtins.listToAttrs
        (map (o: lib.nameValuePair o.name (self.callCabal2nixWithOptions o.name o.src (cabal2nixOptions o.name true) {}))
          cfg.hackage-overlays);

    # Packages rooted outside the project source get pragmatic defaults:
    # without a solver their version bounds routinely need loosening.
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

    # Common `packages` fields that set one mkDerivation argument each,
    # mapped to the argument's name (see generic-builder.nix).
    packagesFieldArgs = {
      doCheck = "doCheck";
      doHaddock = "doHaddock";
      doCoverage = "doCoverage";
      doHoogle = "doHoogle";
      doHyperlinkSource = "hyperlinkSource";
      doQuickjump = "doHaddockQuickjump";
      dontStrip = "dontStrip";
      enableDeadCodeElimination = "enableDeadCodeElimination";
      enableLibraryProfiling = "enableLibraryProfiling";
      profilingDetail = "profilingDetail";
      enableShared = "enableSharedLibraries";
      enableStatic = "enableStaticLibraries";
      enableSeparateDataOutput = "enableSeparateDataOutput";
      enableLibraryForGhci = "enableLibraryForGhci";
    } // lib.genAttrs
      ( [ "hardeningDisable" ]
        ++ lib.concatMap (phase: [ "pre${phase}" "post${phase}" ])
             [ "Unpack" "Patch" "Configure" "Build" "Check" "Haddock" "Install" ] )
      lib.id;

    # Overlay attribute names must never depend on package values, or the
    # fixpoint recurses: presence (super ? name) decides the names, nulls are
    # passed through in the values.
    packageTweaksOverlay = _: super:
      let setArg = attr: value: compose.overrideCabal (drv: { ${attr} = value; });
          appendArg = attr: values: compose.overrideCabal (drv: { ${attr} = drv.${attr} or [] ++ values; });
          tweak = name: t: if super.${name} == null then null else lib.pipe super.${name} (
            lib.optional (t.patches != []) (compose.appendPatches t.patches)
            # flags of generated packages were already applied through cabal2nix
            ++ lib.optionals (t.flags != {} && !(lib.elem name generatedNames))
                 (lib.mapAttrsToList
                   (f: enabled: (if enabled then compose.enableCabalFlag else compose.disableCabalFlag) f)
                   t.flags)
            ++ map (f: compose.appendConfigureFlag "--ghc-option=${f}") t.ghcOptions
            ++ lib.optional (t.configureFlags != []) (compose.appendConfigureFlags t.configureFlags)
            ++ lib.optional (t.setupBuildFlags != []) (appendArg "buildFlags" t.setupBuildFlags)
            ++ lib.optional (t.setupHaddockFlags != []) (appendArg "haddockFlags" t.setupHaddockFlags)
            ++ lib.concatLists (lib.mapAttrsToList
                 (field: attr: lib.optional (t.${field} != null) (setArg attr t.${field}))
                 packagesFieldArgs)
            ++ lib.optional (t.enableProfiling != null)
                 (compose.overrideCabal (drv: {
                   enableLibraryProfiling = t.enableProfiling;
                   enableExecutableProfiling = t.enableProfiling;
                 }))
            ++ lib.optional (t.src != null) (compose.overrideSrc { inherit (t) src; }));
      # tweaks for packages absent from the set are silently ignored
      in lib.mapAttrs tweak
           (lib.filterAttrs (name: _: super ? ${name}) cfg.packages);

    # Project-wide ghcOptions apply to the project's own packages: applying
    # them to the whole set would invalidate the binary cache for the entire
    # dependency closure.
    ghcOptionsOverlay = _: super:
      lib.genAttrs (lib.attrNames discovered)
        (name: lib.pipe super.${name}
          (map (f: compose.appendConfigureFlag "--ghc-option=${f}") cfg.ghcOptions));

    hp = haskellPackages.extend (lib.composeManyExtensions (
      [ localPackagesOverlay srpOverlay hackageOverlay extraDefaultsOverlay packageTweaksOverlay ]
      ++ lib.optional (cfg.ghcOptions != []) ghcOptionsOverlay
      ++ ocfg.overrides));



    # ---- Shell ----

    # What `shell.packages` selects from: the project's packages plus
    # source-repository-packages, tagged the way selection functions expect.
    # Tagging with // preserves outPath, which shellFor's local-package
    # detection compares. The full package set is never offered: it contains
    # null (boot) and throwing (removed) attributes.
    selectionSet =
      lib.genAttrs generatedNames
        (name: hp.${name} // { isLocal = true; identifier = { inherit name; }; });

    selection =
      if cfg.shell.packages != null
      then cfg.shell.packages
      else ps: builtins.filter
        (p: (p.isLocal or false) && !(cfg.source-repository-packages ? ${p.identifier.name or ""}))
        (builtins.attrValues ps);

    # Tools are resolved by name; version requests cannot be honored without
    # a solver and are ignored.
    toolAliases = { cabal = pkgs.cabal-install; };
    resolveTool = name: _:
      let sources = [ ocfg.tool-packages toolAliases pkgs hp ];
          found = lib.findFirst (set: set ? ${name}) null sources;
      in if found == null
         then throw "nix-haskell (nixpkgs driver): cannot find the shell tool \"${name}\"; set nixpkgs.options.tool-packages.\"${name}\""
         else found.${name};

    crossWrappers =
      let mkWrappers = import ../cross-wrappers.nix { inherit pkgs lib; };
          probe = lib.genAttrs (builtins.attrNames pkgs.pkgsCross) (n: n);
      in lib.concatMap (platform: mkWrappers projectCross.${platform}.haskellPackages.ghc)
           (cfg.shell.crossPlatforms probe);

    shell = hp.shellFor ({
      packages = _: selection selectionSet;
      withHoogle = cfg.shell.withHoogle;
      nativeBuildInputs =
        lib.mapAttrsToList resolveTool cfg.shell.tools
        ++ cfg.shell.nativeBuildInputs
        ++ crossWrappers;
      buildInputs = cfg.shell.buildInputs;
      shellHook = cfg.shell.shellHook;
    } // lib.optionalAttrs (cfg.name != null) { name = "${cfg.name}-shell"; }
      // ocfg.shellFor-args);



    # ---- Cross ----

    projectCross = lib.genAttrs (builtins.attrNames pkgs.pkgsCross) (platform:
      import ./driver.nix {
        pkgs = pkgs.pkgsCross.${platform};
        haskellPackages =
          pkgs.pkgsCross.${platform}.haskell.packages.${cfg.compiler}
            or (throw "nix-haskell (nixpkgs driver): pkgsCross.${platform} has no haskell.packages.${cfg.compiler}");
        inherit lib config;
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

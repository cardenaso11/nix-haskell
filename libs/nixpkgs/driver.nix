# The nixpkgs driver core: builds the project from a nixpkgs Haskell package
# set. Parameterized on `pkgs` and `haskellPackages` so cross instantiations
# are one re-application with `pkgs.pkgsCross.<platform>`.
#
# Project interpretation reuses haskell.nix wherever it has something:
# cabal-project-parser for source-repository-package stanzas, host-map for
# cabal's platform names, and (with `nixpkgs.options.use-plan`) the cabal
# plan of the haskell.nix driver for the definitive local package set.
{ pkgs, haskellPackages, lib, config }:

let compose = pkgs.haskell.lib.compose;
    ocfg = config.nixpkgs.options;

    haskell-nix-src = config.inputs."haskell-nix";
    parser = import (haskell-nix-src + "/lib/cabal-project-parser.nix") { inherit pkgs; };
    hostMap = import (haskell-nix-src + "/lib/host-map.nix") pkgs.stdenv;
    project-file = import ./project-file.nix { inherit pkgs parser; };
    conditionHolds = import ./condition.nix { inherit lib hostMap; };
    thunkSource = import ../thunk.nix;



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
             (project-file.discover { src = config.src-cleaned; explicit = ocfg.packages; })
      else if ocfg.use-plan
      then planPackages
      else lib.mapAttrs (_: p: { inherit (p) src; external = false; })
             (project-file.discover { src = config.src-cleaned; });



    # ---- source-repository-packages (skipped under use-plan: the plan
    # already contains them): { <package-name> = <src dir>; } ----

    srpOptionPackages =
      let entry = attrName: spec:
            let hasOutPath = builtins.isAttrs spec && spec ? outPath;
                src = thunkSource
                  ( if hasOutPath then spec
                    else if builtins.isAttrs spec && spec ? src then spec.src
                    else spec );
                condition =
                  if !hasOutPath && builtins.isAttrs spec && spec ? condition
                  then spec.condition else null;
                subdirs =
                  let s = if !hasOutPath && builtins.isAttrs spec then spec.subdir or null else null;
                  in if s == null then [ "." ] else lib.toList s;
                pkgAt = d:
                  let dir = if d == "." then src else src + "/${d}";
                      name = project-file.packageNameIn dir;
                  in if name == null
                     then throw "nix-haskell (nixpkgs driver): no cabal package in ${toString dir} (source-repository-packages.${attrName})"
                     else lib.nameValuePair name dir;
            in lib.optionals (condition == null || conditionHolds condition) (map pkgAt subdirs);
      in builtins.listToAttrs
           (lib.concatLists (lib.mapAttrsToList entry config.source-repository-packages));

    # Stanzas written in the project's own cabal.project.
    srpStanzaPackages =
      let fetch = r:
            if (r.sha256 or null) != null
            then pkgs.fetchgit { url = r.url; rev = r.rev or r.ref; inherit (r) sha256; }
            else builtins.fetchGit
              ({ url = r.url; }
               // lib.optionalAttrs (r ? rev) { inherit (r) rev; }
               // lib.optionalAttrs (r ? ref) { inherit (r) ref; });
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
           (lib.concatLists (map entry (project-file.sourceRepoStanzas config.src-cleaned)));

    srpPackages =
      lib.optionalAttrs (!ocfg.use-plan) (srpOptionPackages // srpStanzaPackages);



    # ---- The package set: one fixpoint extension over the base set ----

    # Cabal flags of generated packages go through cabal2nix, so the
    # dependency graph is computed under the right flag assignment.
    cabal2nixFlags = name:
      let flags = (config.packages.${name} or {}).flags or {};
      in lib.concatStringsSep " "
           (lib.mapAttrsToList
             (f: enabled: "--flag=${lib.optionalString (!enabled) "-"}${f}")
             flags);

    localPackagesOverlay = self: _:
      lib.mapAttrs
        (name: p: self.callCabal2nixWithOptions name p.src (cabal2nixFlags name) {})
        discovered;

    srpOverlay = self: _:
      lib.mapAttrs
        (name: dir: self.callCabal2nixWithOptions name dir (cabal2nixFlags name) {})
        srpPackages;

    hackageOverlay = self: _:
      builtins.listToAttrs
        (map (o: lib.nameValuePair o.name (self.callCabal2nix o.name o.src {}))
          config.hackage-overlays);

    # Packages rooted outside the project source get pragmatic defaults:
    # without a solver their version bounds routinely need loosening.
    externalNames =
      lib.attrNames (lib.filterAttrs (_: p: p.external) discovered)
      ++ lib.attrNames srpPackages
      ++ map (o: o.name) config.hackage-overlays;

    extraDefaultsOverlay = _: super:
      let d = ocfg.extra-package-defaults;
      in lib.genAttrs externalNames (name: lib.pipe super.${name} (
           lib.optional d.jailbreak compose.doJailbreak
           ++ lib.optional (!d.check) compose.dontCheck
           ++ lib.optional (!d.haddock) compose.dontHaddock));

    generatedNames = lib.attrNames discovered ++ lib.attrNames srpPackages;

    # Overlay attribute names must never depend on package values, or the
    # fixpoint recurses: presence (super ? name) decides the names, nulls are
    # passed through in the values.
    packageTweaksOverlay = _: super:
      let tweak = name: t: if super.${name} == null then null else lib.pipe super.${name} (
            lib.optional (t.patches != []) (compose.appendPatches t.patches)
            # flags of generated packages were already applied through cabal2nix
            ++ lib.optionals (t.flags != {} && !(lib.elem name generatedNames))
                 (lib.mapAttrsToList
                   (f: enabled: (if enabled then compose.enableCabalFlag else compose.disableCabalFlag) f)
                   t.flags)
            ++ map (f: compose.appendConfigureFlag "--ghc-option=${f}") t.ghcOptions
            ++ lib.optional (t.doCheck == true) compose.doCheck
            ++ lib.optional (t.doCheck == false) compose.dontCheck
            ++ lib.optional (t.doHaddock == true) compose.doHaddock
            ++ lib.optional (t.doHaddock == false) compose.dontHaddock
            ++ lib.optional (t.src != null) (compose.overrideSrc { inherit (t) src; }));
      # tweaks for packages absent from the set are silently ignored
      in lib.mapAttrs tweak
           (lib.filterAttrs (name: _: super ? ${name}) config.packages);

    # Project-wide ghcOptions apply to the project's own packages: applying
    # them to the whole set would invalidate the binary cache for the entire
    # dependency closure.
    ghcOptionsOverlay = _: super:
      lib.genAttrs (lib.attrNames discovered)
        (name: lib.pipe super.${name}
          (map (f: compose.appendConfigureFlag "--ghc-option=${f}") config.ghcOptions));

    hp = haskellPackages.extend (lib.composeManyExtensions (
      [ localPackagesOverlay srpOverlay hackageOverlay extraDefaultsOverlay packageTweaksOverlay ]
      ++ lib.optional (config.ghcOptions != []) ghcOptionsOverlay
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
      if config.shell.packages != null
      then config.shell.packages
      else ps: builtins.filter
        (p: (p.isLocal or false) && !(config.source-repository-packages ? ${p.identifier.name or ""}))
        (builtins.attrValues ps);

    # Tools are resolved by name; version requests cannot be honored without
    # a solver and are ignored.
    toolAliases = { cabal = pkgs.cabal-install; };
    resolveTool = name: _:
      ocfg.tool-packages.${name}
        or (toolAliases.${name}
        or (pkgs.${name}
        or (hp.${name}
        or (throw "nix-haskell (nixpkgs driver): cannot find the shell tool \"${name}\"; set nixpkgs.options.tool-packages.\"${name}\""))));

    crossWrappers =
      let mkWrappers = import ../cross-wrappers.nix { inherit pkgs lib; };
          probe = lib.genAttrs (builtins.attrNames pkgs.pkgsCross) (n: n);
      in lib.concatMap (platform: mkWrappers projectCross.${platform}.haskellPackages.ghc)
           (config.shell.crossPlatforms probe);

    shell = hp.shellFor ({
      packages = _: selection selectionSet;
      withHoogle = config.shell.withHoogle;
      nativeBuildInputs =
        lib.mapAttrsToList resolveTool config.shell.tools
        ++ config.shell.nativeBuildInputs
        ++ crossWrappers;
      buildInputs = config.shell.buildInputs;
      shellHook = config.shell.shellHook;
    } // lib.optionalAttrs (config.name != null) { name = "${config.name}-shell"; }
      // ocfg.shellFor-args);



    # ---- Cross ----

    projectCross = lib.genAttrs (builtins.attrNames pkgs.pkgsCross) (platform:
      import ./driver.nix {
        pkgs = pkgs.pkgsCross.${platform};
        haskellPackages =
          pkgs.pkgsCross.${platform}.haskell.packages.${config.nixpkgs.compiler}
            or (throw "nix-haskell (nixpkgs driver): pkgsCross.${platform} has no haskell.packages.${config.nixpkgs.compiler}");
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

{ config, lib, nix-haskell-patches, ... }:

{
  imports = [
    (import "${nix-haskell-patches}/js/splitmix" { drivers = [ "haskell-nix" ]; })
  ];

  name = "reflex-todomvc";
  src = ./.;

  source-repository-packages = {
    reflex-dom = {
      src = ./deps/reflex-dom;
      subdir = [ "reflex-dom" "reflex-dom-core" ];
    };
  };

  haskell-nix = {
    extraSrcFiles = {
      library.extraSrcFiles = [
        "static/style.css"
      ];
      exes.reflex-todomvc.extraSrcFiles = [
        "static/style.css"
      ];
    };

    options.shell.withHaddock = false;
  };

  nixpkgs = {
    # Where this driver builds against a compiler newer than the bounds its
    # package set was written for, the bounds are what is wrong: 9.14 ships
    # ghc-experimental 9.1401.0 and template-haskell 2.24, which jsaddle-wasm
    # and dependent-sum-template exclude. Reading cabal.project through cabal
    # brings `exact-configuration` with it, which is what the
    # `allow-newer: *:*` of that same file amounts to for a driver with no
    # solver: Cabal is told every dependency and reads no bound.
    options.use-plan =
      lib.versionAtLeast config.nixpkgs.compiler-version "9.14";

    # The plan carries the project's structure, not the flag assignments of an
    # arch-conditional stanza, and configuring exactly gives a flag the default
    # its cabal file declares. Both differ from what the `!arch(wasm32)` stanza
    # of cabal.project asks for, so assign them for this driver directly. The
    # generated assignments go first and Cabal takes the last one given, so
    # these still decide.
    packages = {
      reflex-dom.flags = {
        use-warp = true;
        webkit2gtk = false;
      };
      reflex-todomvc.flags.webkitgtk = false;

      # nixpkgs builds a Haskell library with profiling on, which reruns every
      # Template Haskell splice in a second pass, and GHCi cannot link
      # `deriveGEq` from dependent-sum-template that way:
      #
      #   GHC.ByteCode.Linker.lookupCE
      #   couldn't find closure:$fDeriveGEQName_$cderiveGEq
      #
      # Profiling is a property of a whole dependency chain rather than of one
      # package, so the dependents go with it: a profiling build of reflex-dom
      # looks for interface files reflex-dom-core no longer has.
      reflex-dom-core.enableLibraryProfiling = false;
      reflex-dom.enableLibraryProfiling = false;
      reflex-todomvc.enableLibraryProfiling = false;
    };

    options.overrides = [
      # test dependency of reflex-dom-core, lives in the reflex-dom
      # repository; never built since checks are off for fetched packages
      (self: super: { chrome-test-utils = null; })
    ];

    # This driver has no wasm compiler of its own worth building against, which
    # is why the matrix gives it a wasm target only through the ghc-wasm-meta
    # pin. Its shell follows: `wasmMeta` in release.nix adds the wasi32 tools.
    shell.crossPlatforms = ps: with ps; [ ghcjs ];
  };

  shell = {
    crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
    packages = ps: with ps; [ reflex-todomvc ];
    withHoogle = false;
  };

}

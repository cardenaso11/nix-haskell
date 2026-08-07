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
    # without a solver, the arch-conditional flag stanzas of cabal.project
    # cannot be followed; assign the flags for this driver directly
    packages = {
      reflex-dom.flags = {
        use-warp = true;
        webkit2gtk = false;
      };
      reflex-todomvc.flags.webkitgtk = false;
    };

    # Where this driver builds against a compiler newer than the bounds its
    # package set was written for, the bounds are what is wrong: 9.14 ships
    # ghc-experimental 9.1401.0 and template-haskell 2.24, which jsaddle-wasm
    # and dependent-sum-template exclude. Configuring exactly is what the
    # `allow-newer: *:*` of cabal.project amounts to for a driver with no
    # solver: Cabal is told the answer and reads no bound.
    options.exact-configuration =
      lib.versionAtLeast config.nixpkgs.compiler-version "9.14";

    options.overrides = [
      # test dependency of reflex-dom-core, lives in the reflex-dom
      # repository; never built since checks are off for fetched packages
      (self: super: { chrome-test-utils = null; })
    ];

    shell.crossPlatforms = ps: with ps; [ ghcjs ];
  };

  shell = {
    crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
    packages = ps: with ps; [ reflex-todomvc ];
    withHoogle = false;
  };

}

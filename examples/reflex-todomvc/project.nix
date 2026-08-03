{ nix-haskell-patches, ... }:

{
  imports = [
    "${nix-haskell-patches}/js/splitmix"
  ];

  name = "reflex-todomvc";
  src = ./.;
  compiler-nix-name = "ghc914";

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
    # no stackage snapshot covers ghc 9.14 yet, so the nixpkgs ghc914
    # package set has neither consistent bounds nor cached builds
    compiler-nix-name = "ghc912";

    # without a solver, the arch-conditional flag stanzas of cabal.project
    # cannot be followed; assign the flags for this driver directly
    packages = {
      reflex-dom.flags = {
        use-warp = true;
        webkit2gtk = false;
      };
      reflex-todomvc.flags.webkitgtk = false;

      # the nixpkgs package set already carries the upstream splitmix fix
      splitmix.patches = [];
    };
    options.overrides = [
      # test dependency of reflex-dom-core, lives in the reflex-dom
      # repository; never built since checks are off for fetched packages
      (self: super: { chrome-test-utils = null; })
    ];
  };

  shell = {
    crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
    packages = ps: with ps; [ reflex-todomvc ];
    withHoogle = false;
  };

}

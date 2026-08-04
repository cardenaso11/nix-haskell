{ nix-haskell-patches, ... }:

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

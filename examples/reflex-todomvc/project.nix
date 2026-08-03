{ config, nix-haskell-patches, ... }:

{
  imports = [
    "${nix-haskell-patches}/js/splitmix"
  ];

  name = "reflex-todomvc";
  src = ./.;
  compiler-nix-name = "ghc914";

  nixpkgs = {
    compiler = "ghc912";
    # webkitgtk (via jsaddle-webkit2gtk) still links libsoup 2
    pkgs = import config.inputs.nixpkgs {
      inherit (config) system;
      config.permittedInsecurePackages = [ "libsoup-2.74.3" ];
    };
    options.overrides = [
      # test dependency of reflex-dom-core, lives in the reflex-dom
      # repository; never built since checks are off for fetched packages
      (self: super: { chrome-test-utils = null; })
    ];
  };

  source-repository-packages = {
    reflex-dom = {
      src = ./deps/reflex-dom;
      subdir = [ "reflex-dom" "reflex-dom-core" ];
    };
  };

  haskell-nix.extraSrcFiles = {
    library.extraSrcFiles = [
      "static/style.css"
    ];
    exes.reflex-todomvc.extraSrcFiles = [
      "static/style.css"
    ];
  };

  haskell-nix.options.shell.withHaddock = false;

  shell = {
    crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
    packages = ps: with ps; [ reflex-todomvc ];
    withHoogle = false;
  };

}

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

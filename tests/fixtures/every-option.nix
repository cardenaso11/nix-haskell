# A project that sets every common option to a non-trivial value, so the
# checks push real values through both drivers' full translation.
{ pkgs, ... }:

{

  name = "every-option";
  src = ./every-option;
  clean-src = true;
  clean-src-patterns = ''
    dist-newstyle
  '';
  compiler-nix-name = "ghc912";

  ghcOptions = [ "-O1" ];

  packages = {
    every-option = {
      flags.demo = true;
      patches = [ ./every-option.patch ];
      ghcOptions = [ "-Wall" ];
      configureFlags = [ "--enable-optimization" ];
      setupBuildFlags = [ "-v1" ];
      setupHaddockFlags = [ "--verbose=1" ];
      doCheck = false;
      doHaddock = false;
      doCoverage = false;
      doHoogle = false;
      doHyperlinkSource = false;
      doQuickjump = false;
      dontStrip = false;
      enableDeadCodeElimination = false;
      enableLibraryProfiling = false;
      enableProfiling = false;
      profilingDetail = "toplevel-functions";
      enableShared = true;
      enableStatic = true;
      enableSeparateDataOutput = false;
      enableLibraryForGhci = false;
      src = ./every-option;
    };
    absent-package.doCheck = false;
  };

  shell = {
    packages = ps: with ps; [ every-option "absent-package" ];
    tools.cabal = "latest";
    buildInputs = [ pkgs.jq ];
    nativeBuildInputs = [ pkgs.gnused ];
    shellHook = "echo every-option";
    withHoogle = false;
    crossPlatforms = _: [];
  };

  source-repository-packages = {
    dep-a = {
      src = ./dep-a;
      condition = "!arch(javascript)";
    };
  };

  hackage-overlays = [
    {
      name = "dep-b";
      version = "0.1.0.0";
      src = ./dep-b;
    }
  ];

  optimizations.expose-all-unfoldings = true;

  inputs.every-option-fixture = ./dep-a;

  isGhcjs = false;
  isWasm = false;

}

{ system ? builtins.currentSystem
, inputs ? {}
, pkgs ?
    if inputs ? nixpkgs
    then import inputs.nixpkgs { inherit system; }
    else import ./pins/nixpkgs { inherit system; }
}:

module:

pkgs.lib.evalModules {
  modules = [
    ./modules

    {
      config.system = pkgs.lib.mkDefault system;
    }
    ({ config, ... }: {
      _module.args.system = pkgs.lib.mkDefault config.system;
      _module.args.pkgs = pkgs.lib.mkDefault
        (import config.inputs.nixpkgs { inherit (config) system; });
    })

    ({ lib, ... }: {
      config.inputs = lib.mapAttrs (_: lib.mkDefault) inputs;
    })

  ] ++ pkgs.lib.toList module;

  specialArgs = {
    nix-haskell-libs = ./libs;
    nix-haskell-modules = ./modules;
    nix-haskell-patches = ./modules/patches;
  };
}

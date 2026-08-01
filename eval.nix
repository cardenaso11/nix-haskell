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
      _module.args.pkgs = pkgs.lib.mkDefault config.importing.nixpkgs;
    })

    ({ lib, options, ... }: {
      config.pins = lib.mapAttrs (_: lib.mkDefault) (builtins.intersectAttrs options.pins inputs);
    })

  ] ++ pkgs.lib.toList module;

  specialArgs = {
    nix-haskell-modules = ./modules;
    nix-haskell-patches = ./modules/patches;
  };
}

{ ... }:

{

  imports = [
    ./common.nix
    ./haskell.nix

    ./cross

    ./inputs.nix
    ./optimizations.nix
  ];

}

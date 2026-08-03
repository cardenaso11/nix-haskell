{ ... }:

{

  imports = [
    ./common.nix

    # Drivers
    ./haskell.nix
    ./nixpkgs

    ./cross

    ./inputs.nix
    ./optimizations.nix
  ];

}

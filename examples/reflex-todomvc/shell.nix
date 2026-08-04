{ system ? builtins.currentSystem, inputs ? {} }:

let project = import ./default.nix { inherit system inputs; };

in {
  haskell-nix = project.haskell-nix.shell;
  nixpkgs = project.nixpkgs.shell;
  nixpkgs-wasm-experimental = project.nixpkgs-wasm-experimental.shell;
}

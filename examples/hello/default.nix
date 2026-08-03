# Build with either driver:
#   nix-build -A nixpkgs.packages.hello
#   nix-build -A haskell-nix.hsPkgs.hello.components.exes.hello
let nix-haskell = import ../../default.nix {};
    project = nix-haskell (import ./project.nix);
in {
  nixpkgs = project.nixpkgs.project;
  haskell-nix = project.haskell-nix.project;
}

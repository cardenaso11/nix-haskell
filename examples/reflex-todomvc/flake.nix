{
  inputs = {
    # This example is part of the nix-haskell repository two directories up,
    # so the flake commands and plain nix-shell/nix-build (which go through
    # default.nix) build from the same checkout, and nix-haskell's pins/
    # submodules are this flake's submodules too: Nix 2.27+ fetches them from
    # the line below, on older Nix add ?submodules=1 to the flake URL.
    self.submodules = true;

    nix-haskell.url = ../..;

    nixpkgs.follows = "nix-haskell/nixpkgs";
  };

  outputs = inputs@{ self, ... }:
    let nixpkgs = if inputs ? "nixpkgs" then inputs.nixpkgs else builtins.getFlake "nixpkgs";
        eachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in {
      legacyPackages = eachSystem (system:
        import ./default.nix { inherit system inputs; } // {
          # every driver, compiler and cross target this example is meant to
          # work for, built both ways
          release = import ./release.nix { inherit system inputs; };
        }
      );

      packages = eachSystem (system:
        let project = import ./default.nix { inherit system inputs; };
        in rec {
          default = haskell-nix;
          haskell-nix = project.haskell-nix.projectCross.wasi32.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc;
          nixpkgs = project.nixpkgs.projectCross.ghcjs.packages.reflex-todomvc;

          # the same wasm target, built with ghc-wasm-meta's GHC 9.12 instead
          # of the drivers' own compilers
          haskell-nix-wasm-meta = project.haskell-nix-wasm-meta.projectCross.wasi32.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc;
          nixpkgs-wasm-meta = project.nixpkgs-wasm-meta.projectCross.wasi32.packages.reflex-todomvc;
        });

      devShells = eachSystem (system:
        let shells = import ./shell.nix { inherit system inputs; };
        in shells // { default = shells.haskell-nix; }
      );
    };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nixcache.reflex-frp.org"
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" # reflex-frp
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = "true";
  };
}

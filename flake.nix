{
  inputs = {
    # pins/haskell-nix is a git submodule; this makes nix fetch it
    # automatically when the flake is fetched over git (Nix 2.27+; on older
    # Nix, add ?submodules=1 to the flake URL).
    self.submodules = true;

    nixpkgs.url = ./pins/nixpkgs;
    haskell-nix.url = ./pins/haskell-nix;

    flake-compat.url = "github:NixOS/flake-compat";
  };

  outputs = inputs@{ self, ... }:
    let nixpkgs = if inputs ? "nixpkgs" then inputs.nixpkgs else builtins.getFlake "nixpkgs";
        eachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in {
      lib = eachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
            nix-haskell = import ./default.nix { inherit system pkgs inputs; };
        in {
          inherit nix-haskell;
        } // nixpkgs.lib.mapAttrs (name: _: module: (nix-haskell module).${name}) (nix-haskell {})
      );

      packages = eachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
            nix-haskell = import ./default.nix { inherit system pkgs inputs; };
            project = nix-haskell { src = ./.; };
        in {
          manual-view = project.manual.view;
          manual-md = project.manual.md;
          manual-man = project.manual.man;
        }
      );

      checks = eachSystem (system:
        import ./tests {
          inherit system inputs;
          pkgs = import nixpkgs { inherit system; };
        }
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

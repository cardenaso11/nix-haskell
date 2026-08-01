{
  inputs = {
    # Dependencies are git submodules under pins/; this makes nix fetch them
    # automatically when the flake is fetched over git (Nix 2.27+; on older
    # Nix, add ?submodules=1 to the flake URL).
    self.submodules = true;

    nixpkgs.url = "git+file:./pins/nixpkgs?shallow=1";
    haskell-nix.url = "git+file:./pins/haskell-nix?shallow=1";
    reflex-platform = {
      url = "git+file:./pins/reflex-platform?shallow=1";
      flake = false;
    };

    flake-compat.url = "github:NixOS/flake-compat";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let eachSystem = nixpkgs.lib.genAttrs
          [ "x86_64-linux"
            "aarch64-linux"
          ];
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

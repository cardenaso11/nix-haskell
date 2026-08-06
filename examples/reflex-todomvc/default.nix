{ system ? builtins.currentSystem, inputs ? {} }:

let nix-haskell = import ../.. { inherit system inputs; };
    project = nix-haskell (import ./project.nix);

    # The wasm target built with ghc-wasm-meta's GHC 9.12 instead of the
    # drivers' own compilers.
    wasm-meta = { nix-haskell-compilers, nix-haskell-patches, lib, ... }: {

      imports = [
        (import "${nix-haskell-compilers}/ghc-wasm-meta" {
          flavour = "9.12";
          version = "9.12.4.20260731";
        })
        (import "${nix-haskell-patches}/wasm/jsaddle-wasm" {})
      ];

      # `project.nix` assigns the flags of the `if !arch(wasm32)` stanza that
      # the nixpkgs driver cannot read, which is what its ghcjs target needs
      # but not this one: the warp backend brings in C libraries that nixpkgs
      # cannot cross-compile to wasi. The haskell.nix driver reads the stanza
      # and never plans them.
      nixpkgs.packages.reflex-dom.flags.use-warp = lib.mkForce false;

    };

in {
  haskell-nix = project.haskell-nix.project;
  nixpkgs = project.nixpkgs.project;

  haskell-nix-wasm-meta = project.haskell-nix.project.override wasm-meta;
  nixpkgs-wasm-meta = project.nixpkgs.project.override wasm-meta;
}

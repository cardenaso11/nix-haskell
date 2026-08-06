{ system ? builtins.currentSystem, inputs ? {} }:

let nix-haskell = import ../.. { inherit system inputs; };
    project = nix-haskell (import ./project.nix);

    # The wasm target built with ghc-wasm-meta's GHC 9.12 instead of the
    # drivers' own compilers.
    wasm-meta = { nix-haskell-compilers, nix-haskell-patches, ... }: {

      imports = [
        (import "${nix-haskell-compilers}/ghc-wasm-meta" {
          flavour = "9.12";
          version = "9.12.4.20260731";
        })
        (import "${nix-haskell-patches}/wasm/jsaddle-wasm" {})
      ];

      # What the `if !arch(wasm32)` stanza of `cabal.project` says, for the
      # driver that cannot read it: reflex-dom's warp backend needs C libraries
      # that nixpkgs cannot cross-compile to wasi. Only the wasi target turns
      # it off, since the ghcjs one is built with the backend on.
      platforms.wasi32.packages.reflex-dom.flags.use-warp = false;

    };

in {
  haskell-nix = project.haskell-nix.project;
  nixpkgs = project.nixpkgs.project;

  haskell-nix-wasm-meta = project.haskell-nix.project.override wasm-meta;
  nixpkgs-wasm-meta = project.nixpkgs.project.override wasm-meta;
}

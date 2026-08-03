# TODO

- Generalize `compiler-nix-name` into a `compiler` option that accepts
  either a name string, resolved in the driver's package sets as today, or
  a compiler package itself: a bindist or a cross compiler such as the wasm
  toolchains of [ghc-wasm-meta](https://github.com/haskell-wasm/ghc-wasm-meta)
  and [ghc-wasm-bindists](https://github.com/haskell-wasm/ghc-wasm-bindists),
  used by the drivers directly.

- Extract haskell.nix's cabal planner into a standalone library: run the
  cabal solver and turn its plan into buildable derivations, without pulling
  in the rest of haskell.nix (its module system, nixpkgs fork and package
  builders).

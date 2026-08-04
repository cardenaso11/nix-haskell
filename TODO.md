# TODO

- Extract haskell.nix's cabal planner into a standalone library: run the
  cabal solver and turn its plan into buildable derivations, without pulling
  in the rest of haskell.nix (its module system, nixpkgs fork and package
  builders).

# The wasm-opt field set, kept at this path for its importers. The
# declarations live in ../bundle-optimizer-options.nix.
{ lib, inherits ? null }:

(import ../bundle-optimizer-options.nix { inherit lib inherits; }).wasm-opt

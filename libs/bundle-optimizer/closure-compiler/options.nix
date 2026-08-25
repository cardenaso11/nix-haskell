# The closure-compiler field set, kept at this path for its importers.
{ lib, inherits ? null }:

(import ../options.nix { inherit lib inherits; }).closure-compiler

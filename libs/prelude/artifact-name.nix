# The output name for a copied artifact:
# - A derivation names itself.
# - A file or a directory inside a derivation is named by its last path
#   component, not by the store path it sits in.
#
# Example:
#
#   artifact-name = import ./artifact-name.nix { inherit lib; };
#
#   artifact-name "${frontend}/bin/frontend.wasm"
#   => "frontend.wasm"
#
#   artifact-name frontend
#   => "frontend-0.1.0.0"
{ lib }:

artifact:

if lib.isDerivation artifact
then artifact.name
else baseNameOf artifact

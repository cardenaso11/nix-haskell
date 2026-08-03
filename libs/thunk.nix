# Resolve a nix-thunk directory to its source, transparently handling both
# states: packed (the directory holds github.json + thunk.nix, so import
# thunk.nix to fetch the pin) and unpacked (the directory is a checkout of
# the dependency itself, so use it directly). Equivalent to nix-thunk's
# thunkSource.
#
# Example:
#
#   import ./thunk.nix ./dep/reflex-dom   # packed: holds github.json + thunk.nix
#   => <the fetched source of the pin>
#
#   import ./thunk.nix ./dep/checkout     # unpacked: a checkout
#   => ./dep/checkout
path:
if builtins.pathExists (path + "/thunk.nix")
then import (path + "/thunk.nix")
else path

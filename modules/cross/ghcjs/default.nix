# GHCJS target support.
#
# `isGhcjs` reports whether the project targets GHCJS, natively or through
# `shell.crossPlatforms`. When it is true, the shell gains Node.js, which
# Template Haskell needs.
#
# `js-optimize` turns a linked `.jsexe` into what ships: closure-compiler
# over its `all.js`, settled by the `closure-compiler` settings.

import ../../../libs/cross/target-module.nix "ghcjs"

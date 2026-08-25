# The C tools a compiler's toolchain names. The list order is the order
# the cabal `--with-*` flags are emitted in. Each row carries:
# 1. `name`: the option under `toolchain`, and the toolchain attribute.
# 2. `flag`: cabal's name for the tool (`--with-<flag>`), which is not
#    always the option's own. cabal calls the C compiler `gcc`.
# 3. `noun`: what the option's description calls the tool.
#
# Example:
#
#   builtins.head (import ./toolchain-tools.nix)
#   => { name = "cc"; flag = "gcc"; noun = "C compiler"; example = "wasm32-wasi-clang"; }
[
  { name = "cc"; flag = "gcc"; noun = "C compiler"; example = "wasm32-wasi-clang"; }
  { name = "ar"; flag = "ar"; noun = "archiver"; example = "llvm-ar"; }
  { name = "ld"; flag = "ld"; noun = "linker"; example = "wasm-ld"; }
  { name = "strip"; flag = "strip"; noun = "strip utility"; example = "llvm-strip"; }
]

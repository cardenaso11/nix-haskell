# The JavaScript side of a wasm program's JSFFI imports, read out of the binary
# by the `post-link.mjs` of the compiler that built it. A GHC-built wasm module
# cannot be instantiated without it: it is what satisfies the module's
# `ghc_wasm_jsffi` import object.
#
# The compiler has to be the one that produced the binary, since post-link.mjs
# reads a custom section its own GHC wrote. `<driver>.cross-compiler` names that
# compiler, so a project does not have to know how a driver keeps them. Run this
# on the binary as linked: `wasm-opt/run.nix` strips those sections away.
#
# Example:
#
#   import ./wasm-jsffi.nix { inherit pkgs; } {
#     ghc = <wasm32-unknown-wasi-ghc-9.14.1>;
#     wasm = "${frontend}/bin/frontend.wasm";
#   }
#   => <derivation frontend.wasm-jsffi>   # an ES module of one export:
#                                         #   export default (__exports) => ({ ... })
{ pkgs }:

{ ghc, wasm }:

let # A whole derivation names itself; a file inside one is named by its own last
    # component, rather than by the store path it sits in.
    name = if pkgs.lib.isDerivation wasm then wasm.name else baseNameOf wasm;

# The libdir is asked for rather than assumed: a version-named install keeps
# post-link.mjs under lib/<prefix>ghc-<version>/lib, a relocatable bindist
# directly under lib.
in pkgs.runCommand "${name}-jsffi" {
  nativeBuildInputs = [ pkgs.nodejs ];
} ''
  node $(${ghc}/bin/${ghc.targetPrefix}ghc --print-libdir)/post-link.mjs -i ${wasm} -o $out
''

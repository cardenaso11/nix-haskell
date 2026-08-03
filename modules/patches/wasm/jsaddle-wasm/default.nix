{ ... }:

{

  # Ignored when the project does not contain jsaddle-wasm.
  config.packages.jsaddle-wasm.patches = [
    ./jsaddle-wasm-initialSyncDepth.patch
  ];

}

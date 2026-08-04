{ drivers ? null }:

let patch = {
      packages.jsaddle-wasm.patches = [
        ./jsaddle-wasm-initialSyncDepth.patch
      ];
    };

in {

  # Ignored when the project does not contain jsaddle-wasm. `drivers` selects
  # the drivers the patch applies to; null applies it to all of them.
  config =
    if drivers == null
    then patch
    else builtins.listToAttrs (map (driver: { name = driver; value = patch; }) drivers);

}

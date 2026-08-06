{ drivers ? null }:

let patch = {
      packages.jsaddle-wasm.patches = [
        ./jsaddle-wasm-initialSyncDepth.patch
      ];
    };

in {

  imports = [

    # Ignored when the project does not contain jsaddle-wasm. `drivers`
    # selects the drivers the patch applies to; null applies it to all of
    # them.
    { config =
        if drivers == null
        then patch
        else builtins.listToAttrs (map (driver: { name = driver; value = patch; }) drivers);
    }

    # nixpkgs records the dependencies jsaddle-wasm's cabal file declares for
    # the build platform, so the one it asks for only under wasm32 is missing
    # from the package database it is configured against.
    ({ pkgs, ... }: {
      config.nixpkgs.options.overrides = [
        (self: super: {
          jsaddle-wasm = pkgs.haskell.lib.compose.addBuildDepend
            self.parser-regex super.jsaddle-wasm;
        })
      ];
    })

  ];

}

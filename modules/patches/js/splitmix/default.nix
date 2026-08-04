{ drivers ? null }:

let patch = {
      packages.splitmix.patches = [
        ./splitmix-js.patch
      ];
    };

in {

  imports = [

    # Ignored when the project does not contain splitmix. `drivers` selects
    # the drivers the patch applies to; null applies it to all of them.
    { config =
        if drivers == null
        then patch
        else builtins.listToAttrs (map (driver: { name = driver; value = patch; }) drivers);
    }

    # splitmix's testu01 test-suite names the testu01 C library, which a
    # Haskell package set cannot resolve when splitmix is built from source;
    # the suite is behind a manual flag and never built.
    { config.nixpkgs.options.overrides = [
        (self: super: { testu01 = null; })
      ];
    }

  ];

}

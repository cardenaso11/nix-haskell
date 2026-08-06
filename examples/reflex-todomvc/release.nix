# Every combination of driver, compiler and cross target this example is meant
# to work for, built two ways: as the drivers build it, and as a person would
# inside the project's shell.
#
#   nix-build release.nix -A build
#   nix-build release.nix -A shell-build
#   nix-build release.nix -A build.haskell-nix.ghc912.wasi32
#
# `wasm-meta` is the same matrix with the wasm target's compiler taken from the
# ghc-wasm-meta pin instead of the driver's own.
#
# Combinations that cannot work are absent rather than failing. The nixpkgs
# driver has no 9.14 Haskell package set worth building against, which is why
# that driver's own compiler is 9.12; and its shell has no wasm tools, because
# it builds a shell's cross tools with nixpkgs' `ghcWithPackages`, which looks
# for a compiler's package database under `lib/<prefix>ghc-<version>` while a
# relocatable bindist keeps it directly under `lib`.
{ system ? builtins.currentSystem, inputs ? {} }:

let nix-haskell = import ../.. { inherit system inputs; };

    lib = (project []).pkgs.lib;

    project = modules: nix-haskell ([ (import ./project.nix) ] ++ modules);

    # The bindist of the same series as the project's compiler. The exact
    # version is what the drivers name package sets and library directories
    # after, so it is given where it is known rather than left to the series in
    # the bindist's name, which would name them differently for the same
    # compiler. The pin carries it in ghcup metadata, which is yaml and so not
    # readable from here.
    wasmMetaVersions = {
      "9.12" = "9.12.4.20260731";
    };

    wasmMeta = series:
      { nix-haskell-compilers, nix-haskell-patches, ... }: {
        imports = [
          (import "${nix-haskell-compilers}/ghc-wasm-meta" {
            flavour = series;
            version = wasmMetaVersions.${series} or null;
          })
          (import "${nix-haskell-patches}/wasm/jsaddle-wasm" {})
        ];

        platforms.wasi32.packages.reflex-dom.flags.use-warp = false;
      };

    variant = series: withWasmMeta:
      project ([ { compiler.name = "ghc${lib.replaceStrings [ "." ] [ "" ] series}"; } ]
        ++ lib.optional withWasmMeta (wasmMeta series));

    # The exe as each driver names it: haskell.nix has a tree of components, the
    # nixpkgs driver one derivation per package.
    driverExe = {
      haskell-nix = p: platform:
        p.haskell-nix.project.projectCross.${platform}.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc;
      nixpkgs = p: platform:
        p.nixpkgs.project.projectCross.${platform}.packages.reflex-todomvc;
    };

    built = driver: series: withWasmMeta: platforms:
      let p = variant series withWasmMeta;
      in lib.genAttrs platforms (platform: driverExe.${driver} p platform);

    # The name of the wrapper that puts a cross target's tools in front of the
    # ones the shell carries for the build platform. It is the target's own
    # prefix, so the compiler a target is built with decides it: haskell.nix
    # builds its wasm compiler for wasm32-unknown-wasi, while the bindist is
    # built for wasm32-wasi.
    dispatcher = withWasmMeta: platform:
      if platform == "ghcjs" then "javascript-unknown-ghcjs"
      else if withWasmMeta then "wasm32-wasi"
      else "wasm32-unknown-wasi";

    # The build a person would run, in the shell they would run it in. cabal
    # needs no package index: the shell's package database already carries
    # everything the project depends on, and a configuration naming no
    # repository is what keeps cabal from fetching one it cannot reach.
    shellBuilt = driver: series: withWasmMeta: platforms:
      let p = variant series withWasmMeta;
          shell = p.${driver}.project.shell;
      in lib.genAttrs platforms (platform:
        shell.overrideAttrs (old: {
          name = lib.concatStringsSep "-" ([ "reflex-todomvc" driver ]
            ++ lib.optional withWasmMeta "wasm-meta"
            ++ [ "ghc${lib.replaceStrings [ "." ] [ "" ] series}" platform "shell-build" ]);

          src = p.${driver}.project.config.src-cleaned;

          phases = [ "unpackPhase" "buildPhase" "installPhase" ];

          buildPhase = ''
            export HOME=$TMPDIR
            export CABAL_CONFIG=$TMPDIR/cabal.config
            echo 'jobs: $ncpus' > $CABAL_CONFIG
            echo 'active-repositories: :none' >> cabal.project.local

            ${dispatcher withWasmMeta platform} cabal build --offline exe:reflex-todomvc
          '';

          installPhase = ''
            mkdir -p $out
            for artifact in dist-newstyle/build/*/*/reflex-todomvc-*/x/reflex-todomvc/build/reflex-todomvc/*; do
              case "$artifact" in
                *-tmp) continue ;;
              esac
              cp -r "$artifact" $out/
            done
          '';
        }));

in {

  build = {

    haskell-nix = {
      ghc912 = built "haskell-nix" "9.12" false [ "ghcjs" "wasi32" ];
      ghc914 = built "haskell-nix" "9.14" false [ "ghcjs" "wasi32" ];
    };

    nixpkgs = {
      ghc912 = built "nixpkgs" "9.12" false [ "ghcjs" ];
    };

    wasm-meta = {

      haskell-nix = {
        ghc912 = built "haskell-nix" "9.12" true [ "ghcjs" "wasi32" ];
        ghc914 = built "haskell-nix" "9.14" true [ "ghcjs" "wasi32" ];
      };

      nixpkgs = {
        ghc912 = built "nixpkgs" "9.12" true [ "ghcjs" "wasi32" ];
        ghc914 = built "nixpkgs" "9.14" true [ "ghcjs" "wasi32" ];
      };

    };

  };

  shell-build = {

    haskell-nix = {
      ghc912 = shellBuilt "haskell-nix" "9.12" false [ "ghcjs" "wasi32" ];
      ghc914 = shellBuilt "haskell-nix" "9.14" false [ "ghcjs" "wasi32" ];
    };

    nixpkgs = {
      ghc912 = shellBuilt "nixpkgs" "9.12" false [ "ghcjs" ];
    };

    wasm-meta = {

      haskell-nix = {
        ghc912 = shellBuilt "haskell-nix" "9.12" true [ "ghcjs" "wasi32" ];
        ghc914 = shellBuilt "haskell-nix" "9.14" true [ "ghcjs" "wasi32" ];
      };

      nixpkgs = {
        ghc912 = shellBuilt "nixpkgs" "9.12" true [ "ghcjs" ];
        ghc914 = shellBuilt "nixpkgs" "9.14" true [ "ghcjs" ];
      };

    };

  };

}

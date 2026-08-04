{ system ? builtins.currentSystem, inputs ? {} }:

let nix-haskell = import ../.. { inherit system inputs; };
    project = nix-haskell (import ./project.nix);

    # ghc-wasm-meta's wasm GHC 9.12 as the wasi32 compiler. A bindist carries
    # none of the attributes the drivers read off a compiler, so they are
    # supplied below; each one is there because a build asked for it. The
    # native entry stays a name, so only the wasm target uses the bindist.
    wasm-meta = { config, lib, pkgs, ... }:
    let ghc-wasm-meta = config.inputs.ghc-wasm-meta;
        haskell-nix-src = config.inputs."haskell-nix";
        wasm-ghc = pkgs.callPackage "${ghc-wasm-meta}/pkgs/wasm32-wasi-ghc.nix" {
          flavour = "9.12";
        };
        # the toolchain the bindist is configured with: its clang carries the
        # wasm target (from the name it is invoked under) and the sysroot
        wasi-sdk = pkgs.callPackage "${ghc-wasm-meta}/pkgs/wasi-sdk.nix" {};
        wasm-cabal = pkgs.callPackage "${ghc-wasm-meta}/pkgs/wasm32-wasi-cabal.nix" {
          flavour = "9.12";
        };

        targetPrefix = "wasm32-wasi-";
        ghcAttr = "ghc9124";

        # A nixpkgs whose wasi32 cross set is built with the bindist's
        # toolchain instead of nixpkgs' own: `replaceCrossStdenv` carries the
        # sdk as the cross `cc`, and each Haskell package runs the sdk's setup
        # hook (which exports CC/AR/LD/...) rather than the cross stdenv's
        # wrappers. `isStatic = false` and shared libraries are the load-
        # bearing part: GHC's wasm TH interpreter loads `.so`s, and the static
        # default sends nixpkgs down its `iserv-proxy` path, which needs the
        # sockets WASI does not have.
        wasmPkgs = import config.inputs.nixpkgs {
          inherit (config) system;

          crossSystem = lib.systems.elaborate lib.systems.examples.wasi32 // {
            isStatic = false;
          };

          # nixpkgs only reads this cc's metadata; GHC and the sdk's setup hook
          # drive the compilation, so the sdk stands in for a wrapper.
          config.replaceCrossStdenv = { buildPackages, baseStdenv }:
            buildPackages.stdenvNoCC.override {
              inherit (baseStdenv) buildPlatform hostPlatform targetPlatform;
              cc = wasi-sdk // {
                isGNU = false;
                isClang = true;
                libc = wasi-sdk.overrideAttrs (attrs: {
                  pname = attrs.name;
                  version = "unstable1";
                });
                inherit targetPrefix;
                bintools = wasi-sdk // {
                  inherit targetPrefix;
                  bintools = wasi-sdk // { inherit targetPrefix; };
                };
              };
            };

          crossOverlays = [
            (final: prev: {
              cabal-install = wasm-cabal;
              haskell = prev.haskell.override (old: {
                buildPackages = lib.recursiveUpdate old.buildPackages {
                  haskell.compiler.${ghcAttr} = wasm-ghc // { inherit targetPrefix; };
                };
              });
            })
            (final: prev: {
              haskell = prev.haskell // {
                packageOverrides = lib.composeManyExtensions [
                  prev.haskell.packageOverrides
                  (hfinal: hprev: {
                    # the version and package-set name come from the stock
                    # compiler, so nixpkgs' library paths stay where its
                    # infrastructure looks for them
                    ghc = wasm-ghc // {
                      inherit (pkgs.haskell.packages.${ghcAttr}.ghc) version haskellCompilerName;
                      inherit targetPrefix;
                    };
                    mkDerivation = args: (hprev.mkDerivation (args // {
                      # GHC's wasm backend runs Template Haskell itself, through
                      # the shared libraries below. nixpkgs would otherwise
                      # proxy it through `iserv-proxy`, which needs `network`,
                      # which needs the sockets WASI does not have.
                      enableExternalInterpreter = false;
                      enableLibraryProfiling = false;
                      enableSharedLibraries = true;
                      enableStaticLibraries = false;
                      doBenchmark = false;
                      doHaddock = false;
                      doCheck = false;
                      jailbreak = true;
                      configureFlags = (args.configureFlags or []) ++ [
                        "--with-ld=${wasi-sdk}/bin/lld"
                        "--with-ar=${wasi-sdk}/bin/ar"
                        "--with-strip=${wasi-sdk}/bin/strip"
                      ];
                      setupHaskellDepends = (args.setupHaskellDepends or []) ++ [
                        wasi-sdk
                      ];
                      preBuild = ''
                        ${args.preBuild or ""}
                        export NIX_CC=$CC
                      '';
                    })).overrideAttrs (attrs: {
                      name = "${attrs.pname}-${targetPrefix}${attrs.version}";
                      preSetupCompilerEnvironment = ''
                        export CC_FOR_BUILD=$CC
                      '';
                    });
                  })
                ];
              };
            })
          ];
        };
    in {
      compiler = {
        ${config.system} = "ghc912";
        ghcjs = "ghc912";
        wasi32 =
          wasm-ghc // {
            compiler-nix-name = "ghc912";
            version = "9.12.4.20260731";
            targetPrefix = "wasm32-wasi-";
            enableShared = true;
            haskellCompilerName = "ghc-9.12.4.20260731";
            # the bindist keeps the package db and settings directly under
            # lib/, not under the lib/<prefix>ghc-<version>/lib the drivers
            # assume for a compiler of this version
            libDir = "lib";
          };
      };

      # `project.nix` assigns the flags of the `if !arch(wasm32)` stanza the
      # nixpkgs driver cannot follow, which is right for its ghcjs target but
      # not here: the warp backend drags in C libraries that nixpkgs cannot
      # cross-compile to wasi (`pkgsCross.wasi32.zlib` does not build). The
      # haskell.nix driver reads the stanza and never plans them.
      nixpkgs.packages.reflex-dom.flags.use-warp = lib.mkForce false;

      # The whole package set is the wasm one, so this driver's own project is
      # the wasm build and `projectCross` is not involved. `haskellPackages` is
      # set explicitly, which is also what takes the `compiler` option out of
      # the picture for this driver: the set already carries the bindist.
      nixpkgs.pkgs = wasmPkgs;
      nixpkgs.haskellPackages = wasmPkgs.haskell.packages.${ghcAttr};

      # nixpkgs' generated metadata for jsaddle-wasm records the dependencies
      # its cabal file declares for the build platform, so the one it asks for
      # only under wasm32 is missing from the package db.
      nixpkgs.options.overrides = [
        (self: super: {
          jsaddle-wasm = wasmPkgs.haskell.lib.compose.addBuildDepend
            self.parser-regex super.jsaddle-wasm;
        })
      ];

      # Only the wasm target is built with the bindist. The tools haskell.nix
      # builds for the build platform go through the same modules, and must
      # keep their native toolchain.
      haskell-nix.overrides = [ ({ config, lib, pkgs, ... }@args: {
        # `mkIf` rather than a conditional module body: `pkgs` comes from
        # `_module.args`, so deciding the module's own attributes on it is a
        # cycle.
        config = lib.mkIf pkgs.stdenv.hostPlatform.isWasm {

          # The bindist's `text` is built against simdutf, so it depends on
          # the compiler's `system-cxx-std-lib`, which is in neither list
          # haskell.nix copies out of the global package db, leaving `text`
          # broken. This option replaces rather than extends, so haskell.nix's
          # own definition is reused instead of restating its contents (it
          # carries `ghci` and friends, which wasm needs for TH).
          nonReinstallablePkgs =
            (import "${haskell-nix-src}/modules/install-plan/non-reinstallable.nix" args).nonReinstallablePkgs
            ++ [ "system-cxx-std-lib" ];

          # The components are built by the cross stdenv, whose toolchain is
          # not the one the bindist was configured with, so anything reaching
          # for C (`Setup configure`'s foreign-dependency checks) looks in the
          # wrong sysroot. Point every package at the bindist's own tools, the
          # ones its wasi-sdk setup hook designates. These flags repeat the
          # ones haskell.nix passes from the cross stdenv and Cabal takes the
          # last, as its own ghcjs case relies on.
          packages = lib.genAttrs config.package-keys (_: {
            configureFlags = [
              "--with-gcc=${wasi-sdk}/bin/wasm32-wasi-clang"
              "--with-ar=${wasi-sdk}/bin/llvm-ar"
              "--with-ld=${wasi-sdk}/bin/wasm-ld"
              "--with-strip=${wasi-sdk}/bin/llvm-strip"
            ];
          });
        };
      }) ];
    };

in {
  haskell-nix = project.haskell-nix.project;
  nixpkgs = project.nixpkgs.project;

  haskell-nix-wasm-meta = project.haskell-nix.project.override wasm-meta;
  nixpkgs-wasm-meta = project.nixpkgs.project.override wasm-meta;
}

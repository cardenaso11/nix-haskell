{ system ? builtins.currentSystem, inputs ? {} }:

let nix-haskell = import ../.. { inherit system inputs; };
    project = nix-haskell (import ./project.nix);
in {
  haskell-nix = project.haskell-nix.project;
  nixpkgs = project.nixpkgs.project;
  nixpkgs-wasm-experimental = project.nixpkgs.project.override ({ config, lib, pkgs, ... }: {
    inputs.nixpkgs = config.inputs.nixpkgs-wasm-experimental;

    # the 9.12 wasm dylibs exceed V8's export limit on jsaddle-dom; 9.14's
    # stay under it
    nixpkgs.compiler-nix-name = "ghc914";

    # the wasm GHC drives its external interpreter (dyld.mjs) with V8 flags
    # of its era: --wasm-lazy-validation no longer exists, and nodejs 24
    # rejects more of them than nodejs 22
    nixpkgs.pkgs = import config.inputs.nixpkgs-wasm-experimental {
      inherit (config) system;
      overlays = [
        (self: super:
          let unLazyValidation = ghc: ghc.overrideAttrs (old: {
                postFixup = (old.postFixup or "") + ''
                  for f in $out/lib/*/lib/dyld.mjs; do
                    if [ -f "$f" ]; then
                      sed -i '1s/ --wasm-lazy-validation//' "$f"
                    fi
                  done
                '';
              });
          in super.lib.optionalAttrs super.stdenv.targetPlatform.isWasm {
            nodejs = super.nodejs_22;
            haskell = super.haskell // {
              compiler = super.haskell.compiler // {
                ghc9125 = unLazyValidation super.haskell.compiler.ghc9125;
                ghc9141 = unLazyValidation super.haskell.compiler.ghc9141;
              };
            };
          })
      ];
    };

    nixpkgs.shell.crossPlatforms = lib.mkForce (ps: with ps; [ ghcjs wasi32 ]);

    # without use-warp the wasi32 set follows reflex-dom's own arch(wasm32)
    # branch instead of dragging warp into the wasm closure
    nixpkgs.packages.reflex-dom.flags = lib.mkForce { webkit2gtk = false; };

    # the generated hackage set is evaluated for linux, so jsaddle-wasm's
    # arch(wasm32) dependency on parser-regex is absent from it
    nixpkgs.options.overrides = [
      (self: super:
        let hlib = pkgs.haskell.lib;
        in {
          # the generated hackage set is evaluated for linux, so jsaddle-wasm's
          # arch(wasm32) dependency on parser-regex is absent from it; the sed
          # lifts the disjunctive ghc-experimental bound jailbreak-cabal cannot
          jsaddle-wasm = hlib.overrideCabal
            (hlib.addBuildDepend super.jsaddle-wasm self.parser-regex)
            (old: {
              jailbreak = true;
              postPatch = (old.postPatch or "") + ''
                sed -Ei 's/ghc-experimental[^,]*/ghc-experimental/' *.cabal
              '';
            });

          # ghc 9.14's boot libraries are ahead of the set's version bounds
          dependent-sum-template = hlib.doJailbreak super.dependent-sum-template;
          dependent-map = hlib.doJailbreak super.dependent-map;
          patch = hlib.doJailbreak super.patch;
          reflex = hlib.doJailbreak super.reflex;
          ghcjs-dom = hlib.doJailbreak super.ghcjs-dom;
          jsaddle-dom = hlib.doJailbreak super.jsaddle-dom;
        })
    ];
  });
}

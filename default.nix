{ system ? builtins.currentSystem
, inputs ? {}
, pkgs ?
    if inputs ? nixpkgs
    then import inputs.nixpkgs { inherit system; }
    else import ./pins/nixpkgs { inherit system; }
}:

with pkgs.lib;

module:

let eval = import ./eval.nix { inherit system pkgs inputs; };

    evaluated = eval module;
    config = evaluated.config;
    options = evaluated.options;

    docs = import ./docs.nix { inherit pkgs options; };

    haskell-nix =
      let mkProject = x:
            let xs = toList x;
                evaled = eval xs;
                proj = evaled.config.haskell-nix.project;
            in {
              config = evaled.config;
              override = y:
                let ys = toList y;
                in mkProject (xs ++ ys);
            } // proj;
      in rec {
        project = mkProject module;

        ghcWithPackages = m: packages:
          let ms = toList m;
              syntheticSrc = pkgs.writeTextFile {
                name = "ghc-with-packages-src";
                destination = "/ghc-with-packages.cabal";
                text = ''
                  cabal-version: 2.4
                  name: ghc-with-packages
                  version: 0

                  library
                    build-depends: ${builtins.concatStringsSep ", " packages}
                '';
              };
              proj = mkProject ([{
                name = "ghc-with-packages";
                src = syntheticSrc;
                cabalProjectLocal = ''
                  extra-packages: ${builtins.concatStringsSep ", " packages}
                '';
              }] ++ ms);
              installPlan = proj.pkg-set.config.plan-json.install-plan;
              preExistingPkgs = filter (p: p.type == "pre-existing") installPlan;
              preExistingPkgsNames = map (p: p.pkg-name) preExistingPkgs;
          in proj.ghcWithPackages (ps: map (n: ps.${n}) (filter (n: !(elem n preExistingPkgsNames)) packages));
      };


in {
  inherit config haskell-nix;

  nixpkgs = evaluated._module.args.pkgs;

  manual = docs;
} // mapAttrs (_: value: { haskell-nix = value; }) haskell-nix

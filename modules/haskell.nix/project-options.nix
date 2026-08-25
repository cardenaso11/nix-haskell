# The `options` option: haskell.nix's own project options, re-imported
# from the checkout so the manual documents them and a project can set any
# of them directly.
{ lib, config, cfg }:

with lib;
with (import ../../libs/prelude { inherit lib; });

{

  options = mkOption {
    default = {};
    description = ''
      haskell.nix project options, passed to haskell.nix's `project`
      function as given. Any option of haskell.nix's own project modules
      can be set here (`index-state`, `cabalProjectFreeze`,
      `extra-hackages`, `pkg-def-extras`, `shell.exactDeps`, ...). The
      driver fills many of them from the common options through its
      `translation` table.
    '';
    type = types.submodule {
      imports = [
        # The documentation generator walks this submodule without the
        # translation's definitions. Defaults of haskell.nix options
        # derive from src, so the walk needs one here. The translation's
        # mkForce wins in the real evaluation.
        { config.src = mkDefault cfg.src-cleaned; }
        ({...}@projectArgs:
          let sources = [
                (config.inputs."haskell-nix" + "/modules/cabal-project.nix")
                (config.inputs."haskell-nix" + "/modules/project-common.nix")
                (config.inputs."haskell-nix" + "/modules/project.nix")
              ];

              moduleArgs = projectArgs // {
                pkgs = config."haskell-nix".nixpkgs;
                haskellLib = config."haskell-nix".lib;
              };

              upstreamOptions = zipAttrsWith (name: vals: last vals)
                (map (module: (import module moduleArgs).options) sources);

              docPatches = {
                evalPackages.defaultText = fenced-code ''
                  if pkgs.pkgsBuildBuild.stdenv.system == config.evalSystem
                  then pkgs.pkgsBuildBuild
                  else
                    import pkgs.path {
                      system = config.evalSystem;
                      overlays = pkgs.overlays;
                    };
                '';
                inputMap.description = ''
                  Specifies the contents of urls in the cabal.project file.
                  For a `source-repository-packages` stanza, haskell.nix
                  checks the `.rev` attribute against the `tag`.

                  For a `revision` block, it reads `inputMap.<url>`, and
                  looks up the `.tar.gz` file of each named package in the
                  `inputMap` as well.
                '';
              };

          in {
            options = recursiveUpdate upstreamOptions docPatches;
          }
        )
      ];
    };
  };

}

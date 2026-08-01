{ config, lib, system, ... }:

with lib;

let haskell-nix = import config.inputs."haskell-nix" { inherit system; };

in {

  options = {

    "haskell-nix" = {

      nixpkgsSource = mkOption {
        type = types.raw;
        default = haskell-nix.sources.nixpkgs-unstable;
        defaultText = literalMD ''
          ```
          (import config.inputs."haskell-nix" { inherit system; }).sources.nixpkgs-unstable
          ```
        '';
      };

      nixpkgsArgs = mkOption {
        type = types.raw;
        default = haskell-nix.nixpkgsArgs;
        defaultText = literalMD ''
          ```
          (import config.inputs."haskell-nix" { inherit system; }).nixpkgsArgs
          ```
        '';
      };

      nixpkgs = mkOption {
        type = types.raw;
        default = import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs);
        defaultText = literalMD ''
          ```
          import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs)
          ```
        '';
      };

      haskell-nix = mkOption {
        type = types.raw;
        default = config."haskell-nix".nixpkgs.haskell-nix;
        defaultText = literalMD ''
          ```
          config."haskell-nix".nixpkgs.haskell-nix
          ```
        '';
      };

      lib = mkOption {
        type = types.raw;
        default = config."haskell-nix".haskell-nix.haskellLib;
        defaultText = literalMD ''
          ```
          config."haskell-nix".haskell-nix.haskellLib
          ```
        '';
      };

      options = mkOption {
        default = {};
        type = types.submodule {
          imports = [
            ({...}@project_args:
              let modules = [
                    (config.inputs."haskell-nix" + "/modules/cabal-project.nix")
                    (config.inputs."haskell-nix" + "/modules/project-common.nix")
                    (config.inputs."haskell-nix" + "/modules/project.nix")
                  ];
                  module_args = project_args // { pkgs = config."haskell-nix".nixpkgs; haskellLib = config."haskell-nix".lib; };
                  options = zipAttrsWith (name: vals: last vals) (map (module: (import module module_args).options) modules);
              in {
                options = recursiveUpdate options {
                  evalPackages.defaultText = literalMD ''
                    ```
                    if pkgs.pkgsBuildBuild.stdenv.system == config.evalSystem
                    then pkgs.pkgsBuildBuild
                    else
                      import pkgs.path {
                        system = config.evalSystem;
                        overlays = pkgs.overlays;
                      };
                    ```
                  '';
                  inputMap.description = ''
                    Specifies the contents of urls in the cabal.project file.
                    The `.rev` attribute is checked against the `tag` for `source-repository-packages`.

                    For `revision` blocks the `inputMap.<url>` will be used and
                    they `.tar.gz` for the `packages` used will also be looked up
                    in the `inputMap`.
                  '';
                };
                config =
                  let c = filterAttrs (n: v: v != null) (intersectAttrs options config);
                  in c // optionalAttrs (c ? shell) {
                    shell = builtins.removeAttrs c.shell [ "shellHook" "withHoogle" ];
                  };
              }
            )
          ];
        };
      };

      project = mkOption {
        default =
          let p = config.haskell-nix.haskell-nix.project config.haskell-nix.options;
          in p // {
            shell = p.shell.overrideAttrs (old: {
              shellHook = old.shellHook + (config.shell.shellHook or "");
              withHoogle = old.withHoogle or (config.shell.withHoogle or false);
            });
          };
        defaultText = literalMD ''
          ```
          config.haskell-nix.haskell-nix.project config.haskell-nix.options
          ```
        '';
        type = types.raw;
      };

    };

  };

  config = {

    haskell-nix.options = {
      src = mkForce config.src-driver;
      hsPkgs = mkDefault null;
    };

  };

}

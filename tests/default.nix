# The repo's checks, exposed as `checks.<system>` by the flake:
#
#   translation-totality        every common option is translated by every
#                               driver, in both directions (pure eval)
#   every-option-<driver>       the every-option fixture instantiates through
#                               the driver's whole translation (no compiling)
#   hello-<driver>              the hello example actually builds
#
# Runnable without the flake: nix-build tests -A translation-totality
{ system ? builtins.currentSystem
, inputs ? {}
, pkgs ?
    if inputs ? nixpkgs
    then import inputs.nixpkgs { inherit system; }
    else import ../pins/nixpkgs { inherit system; }
}:

with pkgs.lib;

let eval = import ../eval.nix { inherit system pkgs inputs; };

    drivers = [ "haskell-nix" "nixpkgs" ];

    fixture = eval ./fixtures/every-option.nix;

    hello = eval (import ../examples/hello/project.nix);

    common = import ../libs/option-names.nix {
      inherit (pkgs) lib;
      options = fixture.options;
      excludes = drivers;
    };

    translation-totality =
      let check = driver:
            let keys = attrNames fixture.config.${driver}.translation;
                missing = subtractLists keys common;
                stale = subtractLists common keys;
            in optional (missing != [])
                 "the ${driver} driver does not translate: ${concatStringsSep ", " missing}"
            ++ optional (stale != [])
                 "the ${driver} driver translates options that do not exist: ${concatStringsSep ", " stale}";
          failures = concatMap check drivers;
      in if failures == []
         then pkgs.runCommand "translation-totality" {} "echo ok > $out"
         else throw (concatStringsSep "\n" failures);

    every-option = driver: pkgs.runCommand "every-option-${driver}" {
      drvPath = builtins.unsafeDiscardStringContext
        fixture.config.${driver}.project.shell.drvPath;
    } "echo $drvPath > $out";

in {
  inherit translation-totality;

  every-option-haskell-nix = every-option "haskell-nix";
  every-option-nixpkgs = every-option "nixpkgs";

  hello-nixpkgs = hello.config.nixpkgs.project.packages.hello;
  hello-haskell-nix = hello.config."haskell-nix".project.hsPkgs.hello.components.exes.hello;
}

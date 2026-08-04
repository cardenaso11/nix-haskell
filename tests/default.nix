# The repo's checks, exposed as `checks.<system>` by the flake:
#
#   translation-totality        every common option is translated by every
#                               driver, in both directions (pure eval)
#   compiler-package            package-valued and per-platform `compiler`
#                               resolve through both drivers (pure eval)
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

    # A package-valued `compiler`, alone and per platform: the haskell.nix
    # driver derives compiler-nix-name and pins the package through
    # compilerSelection (dispatched on the target platform); the nixpkgs
    # driver swaps the package into the base set's ghc; platforms without
    # an entry throw. Pure eval: the stub is never built.
    compiler-package =
      let stub = derivation {
            name = "stub-ghc-9.12.2";
            builder = "/bin/sh";
            inherit system;
          } // { version = "9.12.2"; };

          package = eval { name = "compiler-package"; src = ../examples/hello; compiler = stub; };
          perPlatform = eval {
            name = "compiler-package";
            src = ../examples/hello;
            compiler = { ${system} = "ghc912"; wasi32 = stub; };
          };
          missing = eval { name = "compiler-package"; src = ../examples/hello; compiler = { wasi32 = stub; }; };

          selection = project: p: project.config."haskell-nix".translation.compiler.set.compilerSelection p;
          fakePkgs = platform: {
            stdenv.targetPlatform = platform;
            haskell-nix = { resolve-compiler-name = n: n; compiler.ghc912 = "stock-ghc912"; };
          };
          native = systems.elaborate system;
          wasi = systems.elaborate systems.examples.wasi32;

          failures =
            optional (package.config."haskell-nix".translation.compiler.set.compiler-nix-name != "ghc9122")
              "the haskell.nix driver does not derive ghc9122 from the package version"
            ++ optional ((selection package (fakePkgs native)).ghc9122.name or null != stub.name)
              "the haskell.nix driver's compilerSelection does not return the package"
            ++ optional (package.config.nixpkgs.haskellPackages.ghc.name or null != stub.name)
              "the nixpkgs driver's base set does not carry the package as ghc"
            ++ optional (perPlatform.config."haskell-nix".translation.compiler.set.compiler-nix-name != "ghc912")
              "the haskell.nix driver does not take the project name from the native entry"
            ++ optional ((selection perPlatform (fakePkgs native)).ghc912 or null != "stock-ghc912")
              "a native string entry does not resolve to the stock compiler"
            ++ optional ((selection perPlatform (fakePkgs wasi)).ghc912.name or null != stub.name)
              "a cross package entry is not dispatched on the target platform"
            ++ optional (builtins.tryEval (missing.config.nixpkgs.haskellPackages.ghc.name or null)).success
              "a platform without a `compiler` entry does not throw";
      in if failures == []
         then pkgs.runCommand "compiler-package" {} "echo ok > $out"
         else throw (concatStringsSep "\n" failures);

    every-option = driver: pkgs.runCommand "every-option-${driver}" {
      drvPath = builtins.unsafeDiscardStringContext
        fixture.config.${driver}.project.shell.drvPath;
    } "echo $drvPath > $out";

in {
  inherit translation-totality compiler-package;

  every-option-haskell-nix = every-option "haskell-nix";
  every-option-nixpkgs = every-option "nixpkgs";

  hello-nixpkgs = hello.config.nixpkgs.project.packages.hello;
  hello-haskell-nix = hello.config."haskell-nix".project.hsPkgs.hello.components.exes.hello;
}

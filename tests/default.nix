# The repo's checks, exposed as `checks.<system>` by the flake:
#
#   translation-totality        every common option is translated by every
#                               driver, in both directions (pure eval)
#   compiler-spec               how a compiler is resolved: driver fallbacks,
#                               derived names, the attributes spliced onto a
#                               compiler package, per-platform dispatch and
#                               its toolchain (pure eval)
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

    # How a compiler is resolved: the name a driver falls back to, the names
    # derived from a compiler package, the attributes spliced onto it, and the
    # dispatch of a per-platform entry. Pure eval, so the stubs are never
    # built.
    compiler-spec =
      let stub = version: derivation {
            name = "stub-ghc";
            builder = "/bin/sh";
            inherit system;
          } // { inherit version; };

          sdk = derivation { name = "stub-sdk"; builder = "/bin/sh"; inherit system; };

          project = compiler: eval {
            name = "compiler-spec";
            src = ../examples/hello;
            inherit compiler;
          };

          unset = project {};
          package = project { package = stub "9.12.2"; };
          # a name of its own, and a version the name does not follow from
          named = project {
            name = "ghc912";
            package = stub "9.12.4.20260731";
            haskell-nix.libDir = "lib";
          };
          cross = project {
            name = "ghc912";
            platforms.wasi32 = {
              package = stub "9.12.4.20260731";
              toolchain = {
                package = sdk;
                cc = "clang";
                ar = "ar";
                ld = "ld";
                strip = "strip";
              };
            };
          };

          resolved = p: import ../libs/compiler.nix { inherit (pkgs) lib; } {
            compiler = p.config.compiler;
            inherit system;
          };

          selection = p: pkgs':
            p.config."haskell-nix".translation."compiler.name".set.compilerSelection pkgs';
          fakePkgs = platform: {
            stdenv.targetPlatform = platform;
            haskell-nix = { resolve-compiler-name = n: n; compiler.ghc912 = "stock-ghc912"; };
          };
          native = systems.elaborate system;
          wasi = systems.elaborate systems.examples.wasi32;

          nativeOf = p: (resolved p).native;
          wasiOf = p: (resolved p).resolve "wasi32";

          failures =
            # each driver's own compiler, when the project names none
            optional (unset.config."haskell-nix".compiler.name != "ghc914")
              "the haskell.nix driver does not fall back to ghc914"
            ++ optional (unset.config.nixpkgs.compiler.name != "ghc912")
              "the nixpkgs driver does not fall back to ghc912"
            # a driver default still reaches a field the project left alone
            ++ optional (cross.config.nixpkgs.compiler.platforms.wasi32.targetPrefix != null)
              "a platform entry loses the fields the project did not set"
            # names derived from a package, and the stock name derived from the
            # version rather than from the name
            ++ optional ((nativeOf package).name != "ghc9122")
              "a compiler package's name is not derived from its version"
            ++ optional ((nativeOf named).name != "ghc912")
              "the name the project gave is not kept"
            ++ optional ((nativeOf named).stockName != "ghc9124")
              "the stock name is not derived from the version alone"
            # the attributes both drivers read off a compiler
            ++ optional ((nativeOf named).annotated.libDir or null != "lib")
              "libDir is not spliced onto the compiler"
            ++ optional ((nativeOf named).annotated.haskellCompilerName or null != "ghc-9.12.4.20260731")
              "haskellCompilerName is not derived from the version"
            ++ optional ((nativeOf named).annotated.enableShared or null != true)
              "enableShared does not default to true"
            # platform lookup, and its fall back to the compiler above the table
            ++ optional ((resolved cross).targetKey wasi != "wasi32")
              "a target platform does not find its own entry"
            ++ optional ((resolved cross).targetKey native != system)
              "the native platform does not resolve to the native system"
            ++ optional ((resolved cross).resolve "ghcjs" != (nativeOf cross))
              "a platform without an entry does not use the compiler above the table"
            ++ optional (! (resolved cross).anyToolchain)
              "a toolchain on a platform entry is not noticed"
            ++ optional ((wasiOf cross).toolchainFlags != [
                 "--with-gcc=${sdk}/bin/clang"
                 "--with-ar=${sdk}/bin/ar"
                 "--with-ld=${sdk}/bin/ld"
                 "--with-strip=${sdk}/bin/strip"
               ])
              "the toolchain's configure flags are not what a build is given"
            # a compiler with nothing to name it, and a platform that is not one
            ++ optional (builtins.tryEval (nativeOf (project {
                 package = derivation { name = "nameless"; builder = "/bin/sh"; inherit system; };
               })).name).success
              "a compiler with no version and no name does not fail"
            ++ optional (builtins.tryEval
                 ((resolved (project { platforms.nonsense.name = "ghc912"; })).targetKey wasi)).success
              "a platform key that names no platform does not fail"
            # the drivers, given a compiler package
            ++ optional ((selection package (fakePkgs native)).ghc9122.name or null != (stub "9.12.2").name)
              "the haskell.nix driver's compilerSelection does not return the package"
            ++ optional ((selection cross (fakePkgs native)).ghc912 or null != "stock-ghc912")
              "a project without its own native compiler does not use the driver's"
            ++ optional ((selection cross (fakePkgs wasi)).ghc912.name or null != (stub "9.12.4.20260731").name)
              "a platform entry is not dispatched on the target platform"
            ++ optional (package.config.nixpkgs.haskellPackages.ghc.name or null != (stub "9.12.2").name)
              "the nixpkgs driver's base package set does not carry the compiler";
      in if failures == []
         then pkgs.runCommand "compiler-spec" {} "echo ok > $out"
         else throw (concatStringsSep "\n" failures);

    every-option = driver: pkgs.runCommand "every-option-${driver}" {
      drvPath = builtins.unsafeDiscardStringContext
        fixture.config.${driver}.project.shell.drvPath;
    } "echo $drvPath > $out";

in {
  inherit translation-totality compiler-spec;

  every-option-haskell-nix = every-option "haskell-nix";
  every-option-nixpkgs = every-option "nixpkgs";

  hello-nixpkgs = hello.config.nixpkgs.project.packages.hello;
  hello-haskell-nix = hello.config."haskell-nix".project.hsPkgs.hello.components.exes.hello;
}

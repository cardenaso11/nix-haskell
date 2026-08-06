# Driver-neutral project options.
#
# Every option in this module is honored by every driver: the totality check
# compares these options against each driver's `translation` table, so adding
# an option here without teaching every driver about it fails evaluation.
# Anything only one backend can honor belongs in the driver's own module
# instead.

{ config, lib, pkgs, ... }:

with lib;

let mkDriverDefault = import ../libs/driver-default.nix { inherit lib; };

    # The fields of a compiler entry, shared by the native compiler and the
    # per-platform ones. Fields only one driver reads sit under that driver's
    # own key. Every default is literal, `null` or empty: what a field falls
    # back to depends on the driver (`name`) or on the package (the rest), and
    # each driver resolves it for itself, taking the field, then the attribute
    # the package carries, then a neutral value. A default resolved here could
    # not do that job, because a driver's mirror seeds every field of a
    # submodule option as soon as one of them is defined, which would freeze a
    # single answer into both drivers.
    compilerEntry = {

      name = mkOption {
        type = types.nullOr types.str;
        default = null;
        defaultText = literalMD ''
          `null`: the driver's own compiler, `ghc914` for haskell.nix and
          `ghc912` for nixpkgs, where no stackage snapshot covers 9.14 yet
        '';
        example = "ghc912";
        description = ''
          The compiler's name in the driver's package sets
          (`haskell-nix.compiler.<name>`, `pkgs.haskell.packages.<name>`),
          and the name the project's packages are pinned under. With
          `package` set it names the set whose compiler the package replaces,
          and only needs to be given when the name derived from the version
          is not one the driver knows.
        '';
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = ''
          A compiler used directly instead of one from the driver's package
          sets: a bindist, an out-of-tree cross compiler, a locally built
          GHC. The fields around it are spliced onto it, since both drivers
          read them off the compiler itself and a bindist generally carries
          none of them.
        '';
      };

      version = mkOption {
        type = types.nullOr types.str;
        default = null;
        defaultText = literalMD ''
          `null`: the `version` of `package`, else the version in its name
        '';
        example = "9.12.4.20260731";
        description = ''
          The compiler's version. Both drivers read it off the compiler, for
          paths and for `impl(ghc >= ...)` conditionals, and the stock
          compiler of the same major.minor.patch is what the builds that
          cannot use the package itself fall back to: the nixpkgs package set
          the project is built against, and haskell.nix's shell tools. Worth
          setting for a nightly bindist, whose name carries only its series.
        '';
      };

      targetPrefix = mkOption {
        type = types.nullOr types.str;
        default = null;
        defaultText = literalMD ''
          `null`: the `targetPrefix` of `package`, else the empty string
        '';
        example = "wasm32-wasi-";
        description = ''
          The prefix the compiler's executables carry. Every tool either
          driver invokes is named with it.
        '';
      };

      enableShared = mkOption {
        type = types.nullOr types.bool;
        default = null;
        defaultText = literalMD ''
          `null`: the `enableShared` of `package`, else `true`
        '';
        description = ''
          Whether the compiler can build shared libraries. The haskell.nix
          driver reads it for every component's `shared:` flag; the nixpkgs
          driver builds a cross package set non-static, with shared and not
          static libraries. GHC's wasm backend needs it, because its Template
          Haskell interpreter loads shared objects.
        '';
      };

      toolchain = mkOption {
        default = {};
        description = ''
          The C toolchain the compiler was configured with, when that is not
          the one the surrounding package set supplies. Everything built with
          the compiler is pointed back at it, since `Setup configure`'s
          foreign-dependency checks otherwise look in the wrong sysroot: the
          haskell.nix driver passes it as every package's configure flags,
          the nixpkgs driver makes it the cross package set's toolchain
          outright.
        '';
        type = types.submodule {
          options = {

            package = mkOption {
              type = types.nullOr types.package;
              default = null;
              description = ''
                The toolchain itself. The nixpkgs driver also makes it a
                setup dependency of every package, so that a setup hook
                exporting `CC`, `AR` and friends is honored.
              '';
            };

            cc = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "wasm32-wasi-clang";
              description = ''
                The C compiler's name in the toolchain's `bin`, passed to
                cabal as `--with-gcc`.
              '';
            };

            ar = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "llvm-ar";
              description = ''
                The archiver's name in the toolchain's `bin`, passed to cabal
                as `--with-ar`.
              '';
            };

            ld = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "wasm-ld";
              description = ''
                The linker's name in the toolchain's `bin`, passed to cabal
                as `--with-ld`.
              '';
            };

            strip = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "llvm-strip";
              description = ''
                The strip utility's name in the toolchain's `bin`, passed to
                cabal as `--with-strip`.
              '';
            };

          };
        };
      };

      haskell-nix = mkOption {
        default = {};
        description = ''
          Compiler details only the haskell.nix driver reads.
        '';
        type = types.submodule {
          options = {

            libDir = mkOption {
              type = types.nullOr types.str;
              default = null;
              defaultText = literalMD ''
                `null`: the `libDir` of `package`, else the path haskell.nix
                derives from the version
              '';
              example = "lib";
              description = ''
                The compiler's library directory, relative to its store path,
                where the driver looks for the package database and
                `settings`. A relocatable bindist keeps them directly under
                `lib`, rather than under the `lib/<prefix>ghc-<version>/lib`
                of a version-named install.
              '';
            };

            extraNonReinstallablePkgs = mkOption {
              type = types.listOf types.str;
              default = [];
              example = [ "system-cxx-std-lib" ];
              description = ''
                Packages taken from the compiler's own database rather than
                built, on top of the ones the driver already treats that way.
                A package the compiler was configured against, but which is
                absent from the lists the driver copies out of it, belongs
                here: a build that reaches for it finds nothing to depend on,
                and everything downstream of it breaks. A compiler whose
                `text` is built against simdutf needs `system-cxx-std-lib`
                this way.
              '';
            };

          };
        };
      };

      nixpkgs = mkOption {
        default = {};
        description = ''
          Compiler details only the nixpkgs driver reads.
        '';
        type = types.submodule {
          options = {

            haskellCompilerName = mkOption {
              type = types.nullOr types.str;
              default = null;
              defaultText = literalMD ''
                `null`: the `haskellCompilerName` of `package`, else
                `ghc-<version>`
              '';
              example = "ghc-9.12.4.20260731";
              description = ''
                The compiler's cabal name. The driver names the package
                database directories of everything it builds after it, and
                passes it to cabal2nix as `--compiler`.
              '';
            };

            enableExternalInterpreter = mkOption {
              type = types.nullOr types.bool;
              default = null;
              defaultText = literalMD ''
                `null`: nixpkgs' own choice, which is to use the external
                interpreter whenever it is cross-compiling and an emulator
                exists for the target
              '';
              description = ''
                Whether to run Template Haskell splices through nixpkgs'
                external interpreter, which proxies them to the target over a
                socket. `false` for a compiler that runs splices itself, such
                as GHC's wasm backend, and necessary for a target that has no
                sockets to proxy over.
              '';
            };

          };
        };
      };

    };

in {

  # Recursive so that `platforms` can carry the `packages` option itself
  # rather than a copy of it.
  options = rec {

    system = mkOption {
      type = types.str;
      default = builtins.currentSystem;
      defaultText = ''
        builtins.currentSystem
      '';
      description = ''
        The system the project is built on. Each driver instantiates its
        package set for it, and a cross target is named relative to it.
      '';
    };

    name = mkOption {
      type = types.nullOr types.str;
      default = if isPath config.src
        then baseNameOf config.src
        else getName config.src;
      description = ''
        Optional name for better error messages.
      '';
    };

    src = mkOption {
      type = types.either types.path types.package;
      example = "./.";
      description = ''
        The project source: the tree holding the cabal project file and the
        packages it names. A path is copied into the store, filtered first
        when `clean-src` is enabled; a derivation or a store path is used as
        it is, on the grounds that whatever produced it already chose what it
        contains.
      '';
    };

    clean-src = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Filter `src` through the `.gitignore` it carries before copying it into
        the store, so build artifacts (`dist-newstyle`, `result`, `.git`) do not
        become part of every derivation that names the project source, and a
        rebuild does not rehash them. Only applies when `src` is a path; a
        derivation is used as-is.
      '';
    };

    clean-src-ignore-files = mkOption {
      type = types.listOf types.str;
      default = [ "/.gitignore" ];
      description = ''
        The ignore files read when `clean-src` is enabled, relative to the root
        of the source tree. Every pattern is interpreted with the root as its
        base, whichever file it came from, so an anchored pattern in a nested
        file (`dist/*`) matches against the root rather than against the
        directory the file sits in; where that matters, give the pattern
        through `clean-src-patterns` instead.
      '';
      example = [ "/.gitignore" "/frontend/.gitignore" ];
    };

    clean-src-patterns = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra gitignore-syntax patterns, applied on top of the files
        `clean-src-ignore-files` names, when `clean-src` is enabled. A bare
        pattern (`dist-js`) matches at any depth, which is what an anchored one
        read against the root cannot do.
      '';
      example = ''
        dist-wasm
        dist-js
      '';
    };

    src-cleaned = mkOption {
      type = types.either types.path types.package;
      readOnly = true;
      default =
        if config.clean-src
        then import ../libs/clean-source.nix { inherit pkgs; } {
               src = config.src;
               name = config.name;
               ignoreFiles = config.clean-src-ignore-files;
               patterns = config.clean-src-patterns;
             }
        else config.src;
      defaultText = literalMD ''
      ```
        import ../libs/clean-source.nix { inherit pkgs; } {
          src = config.src;
          name = config.name;
          ignoreFiles = config.clean-src-ignore-files;
          patterns = config.clean-src-patterns;
        }
      ```
      '';
      description = ''
        `src` with build artifacts filtered out, or `src` itself when
        `clean-src` is disabled. This is what the project is actually built
        from.
      '';
    };

    compiler = mkOption {
      default = {};
      description = ''
        The GHC to build with. `name` selects one of the driver's own
        compilers; `package` supplies one from outside them, and the fields
        around it are the attributes the drivers read off a compiler.
        `platforms` gives cross targets their own compiler and toolchain; a
        platform without an entry uses the fields above it.

        A compiler that has to be described this way is worth writing once:
        the modules under `nix-haskell-compilers` are ready-made entries for
        compilers distributed outside the drivers' package sets.
      '';
      example = literalExpression ''
        {
          name = "ghc912";

          # a bindist for the wasm target, with the toolchain it was built
          # with, as `nix-haskell-compilers/ghc-wasm-meta` supplies it
          platforms.wasi32 = {
            package = wasm-ghc;
            version = "9.12.4.20260731";
            targetPrefix = "wasm32-wasi-";
            enableShared = true;
            haskell-nix.libDir = "lib";
            nixpkgs.enableExternalInterpreter = false;
            toolchain = {
              package = wasi-sdk;
              cc = "wasm32-wasi-clang";
              ar = "llvm-ar";
              ld = "wasm-ld";
              strip = "llvm-strip";
            };
          };
        }
      '';
      type = types.submodule {
        options = compilerEntry // {

          platforms = mkOption {
            type = types.attrsOf (types.submodule { options = compilerEntry; });
            default = {};
            description = ''
              Per-platform compilers, keyed by `pkgsCross` platform name (the
              keys of `shell.crossPlatforms` and `projectCross`). An entry has
              the same fields as the compiler above, and the fields it leaves
              unset are resolved from its own `package` rather than inherited.
              A per-driver definition anywhere under `compiler.platforms`
              replaces the whole table for that driver, since a mirror seeds
              submodule fields only one level deep.
            '';
          };

        };
      };
    };

    ghcOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        GHC flags applied project-wide.
      '';
      example = [ "-O2" "-fexpose-all-unfoldings" ];
    };

    cabalProject = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = ''
        Content of the `cabal.project` file. `null` uses the file carried by
        the source.
      '';
    };

    cabalProjectLocal = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = ''
        Content of the `cabal.project.local` file.
      '';
    };

    cabalProjectFileName = mkOption {
      type = types.str;
      default = "cabal.project";
      description = ''
        Name of the cabal project file.
      '';
    };

    extraCabalProject = mkOption {
      type = types.listOf types.lines;
      default = [];
      description = ''
        Lines to append to `cabal.project`.
      '';
    };

    inputMap = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Specifies the contents of urls in the cabal.project file, so sources
        named there resolve without fetching.
        The `.rev` attribute is checked against the `tag` for `source-repository-packages`.
      '';
      example = literalMD ''
        ```
          inputMap = {
            "{url}/{rev/ref}" = dep_src;
            "https://github.com/obsidiansystems/obelisk-oauth.git/a528c0542e9c30851e7c4542468a053fa5e482ef" = thunkSource ./dep/{thunk};
          };
        ```
      '';
    };

    sha256map = mkOption {
      type = types.nullOr (types.attrsOf (types.either types.str (types.attrsOf types.str)));
      default = null;
      description = ''
        An alternative to adding `--sha256` comments into the cabal.project file.
      '';
      example = literalMD ''
        ```
          sha256map = {
            "url"."rev/ref" = "hash"
            "https://github.com/jgm/pandoc-citeproc"."0.17" = "0dxx8cp2xndpw3jwiawch2dkrkp15mil7pyx7dvd810pwc22pm2q";
            "https://github.com/obsidiansystems/obelisk-oauth.git"."a528c0542e9c30851e7c4542468a053fa5e482ef" = lib.fakeHash;
          };
        ```
      '';
    };

    platforms = mkOption {
      type = types.attrsOf (types.submodule {
        options.packages = packages // {
          description = ''
            Per-package customization for this platform only, merged over the
            project-wide `packages`. The fields are the same.
          '';
        };
      });
      default = {};
      description = ''
        Per-platform customization, keyed by `pkgs.pkgsCross` platform name
        (the keys of `shell.crossPlatforms` and `projectCross`).

        A cabal file or project file can make a package's flags, and through
        them its dependencies, conditional on the platform. The haskell.nix
        driver follows those conditionals through its solver; the nixpkgs
        driver has none, so what they would have decided is given here. The
        flags reach the point where a package's dependencies are worked out,
        rather than only how it is configured.
      '';
      example = literalMD ''
        ```
        {
          wasi32.packages.reflex-dom.flags.use-warp = false;
        }
        ```
      '';
    };

    packages = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          flags = mkOption {
            type = types.attrsOf types.bool;
            default = {};
            description = ''
              Cabal flag assignments for the package (`true` enables,
              `false` disables).
            '';
          };
          patches = mkOption {
            type = types.listOf types.path;
            default = [];
            description = ''
              Patches applied to the package source.
            '';
          };
          ghcOptions = mkOption {
            type = types.listOf types.str;
            default = [];
            description = ''
              GHC flags for this package only.
            '';
          };
          configureFlags = mkOption {
            type = types.listOf types.str;
            default = [];
            description = ''
              Extra flags passed to `Setup configure`.
            '';
          };
          setupBuildFlags = mkOption {
            type = types.listOf types.str;
            default = [];
            description = ''
              Extra flags passed to `Setup build`.
            '';
          };
          setupHaddockFlags = mkOption {
            type = types.listOf types.str;
            default = [];
            description = ''
              Extra flags passed to `Setup haddock`.
            '';
          };
          doCheck = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to run the package's test suites. `null` leaves the
              default in place.
            '';
          };
          doHaddock = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to build the package's documentation. `null` leaves the
              default in place.
            '';
          };
          doCoverage = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to generate a coverage report for the package. `null`
              leaves the default in place.
            '';
          };
          doHoogle = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to generate a hoogle index for the package's
              documentation. `null` leaves the default in place.
            '';
          };
          doHyperlinkSource = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to generate hyperlinked source code alongside the
              package's documentation. `null` leaves the default in place.
            '';
          };
          doQuickjump = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to generate the quickjump index of the package's
              documentation. `null` leaves the default in place.
            '';
          };
          dontStrip = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to skip stripping the produced binaries. `null` leaves
              the default in place.
            '';
          };
          enableDeadCodeElimination = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to eliminate unused code at link time. `null` leaves the
              default in place.
            '';
          };
          enableLibraryProfiling = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to build the package's library with profiling support.
              `null` leaves the default in place.
            '';
          };
          enableProfiling = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to build the whole package with profiling support.
              `null` leaves the default in place.
            '';
          };
          profilingDetail = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              The profiling detail level. `null` leaves the default in place.
            '';
            example = "toplevel-functions";
          };
          enableShared = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to build a shared library. `null` leaves the default in
              place.
            '';
          };
          enableStatic = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to build a static library. `null` leaves the default in
              place.
            '';
          };
          enableSeparateDataOutput = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to install the package's data files into a separate
              output. `null` leaves the default in place.
            '';
          };
          enableLibraryForGhci = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Whether to build a pre-linked object of the library for loading
              into GHCi. `null` leaves the default in place.
            '';
          };
          hardeningDisable = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = ''
              Hardening flags to disable when building the package. `null`
              leaves the default in place.
            '';
            example = [ "format" ];
          };
          src = mkOption {
            type = types.nullOr (types.either types.path types.package);
            default = null;
            description = ''
              Replacement source for the package.
            '';
          };
        } // (
          # Hooks around the build phases: preUnpack, postUnpack, ...,
          # preInstall, postInstall.
          let hook = pre: phase:
                nameValuePair "${if pre then "pre" else "post"}${phase}" (mkOption {
                  type = types.nullOr types.lines;
                  default = null;
                  description = ''
                    Shell code run ${if pre then "before" else "after"} the
                    ${toLower phase} phase. `null` leaves the default in
                    place.
                  '';
                });
          in listToAttrs (concatMap (phase: [ (hook true phase) (hook false phase) ])
               [ "Unpack" "Patch" "Configure" "Build" "Check" "Haddock" "Install" ])
        );
      });
      default = {};
      description = ''
        Per-package customization, keyed by cabal package name. Entries for
        packages that do not exist in the final package set are silently
        ignored, so platform-conditional packages can be customized
        unconditionally.
      '';
      example = literalMD ''
        ```
        {
          splitmix.patches = [ ./splitmix-js.patch ];
          reflex-dom-core.doCheck = false;
          my-app.flags.production = true;
        }
        ```
      '';
    };



    shell = mkOption {
      default = {};
      description = ''
        Development shell configuration.
      '';
      type = types.submodule {
        options = {

          packages = mkOption {
            type = types.nullOr types.unspecified;
            default = null;
            defaultText = literalMD ''
              `null` (all local packages that are not
              `source-repository-packages` are selected)
            '';
            apply = selection:
              let resolveEntry = ps: entry:
                    if ! builtins.isString entry then [ entry ]
                    else let package = ps.${entry} or null;
                         in optional (package != null) package;
              in if selection == null
                 then null
                 else ps: concatMap (resolveEntry ps) (selection ps);
            description = ''
              Package selection function. It takes a set of Haskell packages and returns a subset of these packages with all of their dependencies included in `ghc-pkg list`.
              It can take either a `package` or name (`string`) of a package which availability can depend on the platform.
            '';
            example = literalMD ''
              ```
              ps: with ps; [
                common
                frontend
                "backend" # Provided by name so that it is only included when it's among `ps`
              ]
              ```
            '';
          };

          tools = mkOption {
            type = types.attrsOf types.raw;
            default = {};
            description = ''
              Haskell tools available in the shell, keyed by executable name.
              The value is a version request such as `"latest"`, a version
              string, or a tool argument set.
            '';
            example = literalMD ''
              ```
              { cabal = "latest"; haskell-language-server = "latest"; }
              ```
            '';
          };

          buildInputs = mkOption {
            type = types.listOf types.package;
            default = [];
            description = ''
              Extra packages available in the shell.
            '';
          };

          nativeBuildInputs = mkOption {
            type = types.listOf types.package;
            default = [];
            description = ''
              Extra native packages available in the shell.
            '';
          };

          shellHook = mkOption {
            type = types.lines;
            default = "";
            description = ''
              Shell hook to run when entering the shell.
            '';
          };

          withHoogle = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Provide a hoogle database over the shell's package set.
            '';
          };

          crossPlatforms = mkOption {
            type = types.unspecified;
            default = _: [];
            defaultText = literalMD ''
              ```
              ps: []
              ```
            '';
            description = ''
              Selector for cross-compilation targets, over an attribute set
              keyed by `pkgs.pkgsCross` platform names.
            '';
            example = literalMD ''
              ```
              ps: with ps; [ ghcjs wasi32 ]
              ```
            '';
          };

        };
      };
    };



    source-repository-packages = mkOption {
      type = types.attrsOf (types.either types.path types.attrs);
      default = {};
      description = ''
        Local packages to add to the project. A source is anything `inputs`
        accepts, so a packed thunk directory can be given as-is and is
        resolved to the source it pins.

        `subdir` selects packages within the source, so a multi-package
        repository needs one entry rather than one per package.
      '';
      example = literalMD ''
        ```
        {
          obelisk-frontend = deps.obelisk + "/lib/frontend";
          obelisk-backend = {
            src = deps.obelisk + "/lib/backend";
            condition = "!arch(javascript)";
          };

          reflex-dom = deps.reflex-dom + "/reflex-dom";
          reflex-dom-core = deps.reflex-dom + "/reflex-dom-core";
          reflex = deps.reflex;
        }
        ```
      '';
    };



    hackage-overlays = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = ''
        Packages to make visible to dependency resolution without being
        published to Hackage. A good example of this is
        obelisk-generated-static.
      '';
      example = literalMD ''
        ```
        [
          {
            name = "android-activity";
            version = "0.1.1";
            src = pkgs.fetchFromGitHub {
              owner = "obsidiansystems";
              repo = "android-activity";
              rev = "2bc40f6f907b27c66428284ee435b86cad38cff8";
              sha256 = "sha256-AIpbe0JZX68lsQB9mpvR7xAIct/vwQAARVHAK0iChV4=";
            };
          }
        ]
        ```
      '';
    };

  };



  config = {

    shell = {

      tools = {
        # re-applied inside each driver's mirror, where it must stay below
        # the seeds carrying the top-level values
        cabal = mkDriverDefault "latest";
      };

    };

  };

}

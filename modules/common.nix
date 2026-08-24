# Driver-neutral project options.
#
# Every option in this module is honored by every driver. The totality check
# compares these options against each driver's `translation` table, so
# adding an option here without teaching every driver about it fails
# evaluation. Anything only one backend can honor belongs in the driver's
# own module instead.

# `topConfig` is the project's own config: `config` itself at the top level,
# and the enclosing project when a driver mirrors this module for itself.
# Options settled once for the whole project rather than per driver are read
# from it. The bundle optimizers live outside this module, so a mirror has
# no declaration of them to read.
{ config, lib, pkgs, topConfig ? config, ... }:

with lib;
with (import ../libs/prelude { inherit lib; });

let mkDriverDefault = import ../libs/driver-default.nix { inherit lib; };

    packageFields = import ../libs/package-fields.nix { inherit lib; };

    toolchainTools = import ../libs/toolchain-tools.nix;

    toolOption = tool: nameValuePair tool.name (mkOption {
      type = types.nullOr types.str;
      default = null;
      inherit (tool) example;
      description = "The ${tool.noun}'s name in the toolchain's `bin`, passed to cabal as `--with-${tool.flag}`.\n";
    });

    # The defaultText of a compiler field that is read off `package` when
    # the option is unset.
    fromPackage = field: fallback:
      literalMD "`null`: the `${field}` of `package`, else ${fallback}\n";

    # One layer of the bundle optimizer settings, nullable throughout. The
    # values live in the top-level `wasm-opt` and `closure-compiler`, and a
    # `null` here states nothing, so the layer beneath decides.
    # `wasm-optimize` and `js-optimize` resolve the layers, and they are the
    # only readers, so no driver is taught anything about these.
    bundleOptimizerLayer = import ../libs/bundle-optimizer-options.nix {
      inherit lib;
      inherits = "the layer beneath it, and last to the tool's own settings at the top level";
    };

    crossPlatform = import ../libs/cross-platform.nix { inherit lib; };

    crossTargets = import ../libs/cross-targets.nix { inherit lib; };

    # What a driver built for one executable of one cross target, and what
    # that target's optimizer makes of it. Only a driver knows what it
    # built, so these answer when the tree is read through one, as
    # `config.<driver>.platforms.<platform>.packages.<package>....`. Read at
    # the top level, where there is no driver to ask, they are `null`. A
    # project that has something else to ship can define either of them
    # instead.
    bundleFields = { platform, package, exe }:
      let named = { inherit platform package exe; };

          carrier = config.cross-exe named;

          artifact = extension: "${carrier}/bin/${exe}${extension}";

          target = crossPlatform.targetFor platform;

          throughDriver = config ? cross-exe;

      in {

        optimized = mkOption {
          type = types.nullOr types.package;
          default =
            let rowFor = findFirst (row: target.${row.flag}) null crossTargets;
            in if ! throughDriver || rowFor == null
               then null
               else topConfig.${rowFor.optimize}
                 (named // { ${rowFor.artifact} = artifact rowFor.extension; });
          defaultText = literalMD ''
            the executable this driver built for this target, through
            `wasm-optimize` or `js-optimize`
          '';
          description = ''
            What gets shipped: the executable a driver built for this
            target, sent through that target's optimizer. `null` for a
            target that has no optimizer, and `null` when read anywhere but
            through a driver.
          '';
        };

        jsffi = mkOption {
          type = types.nullOr types.package;
          default =
            if throughDriver && target.isWasm
            then topConfig.wasm-jsffi {
              ghc = config.cross-compiler platform;
              wasm = artifact ".wasm";
            }
            else null;
          defaultText = literalMD ''
            `wasm-jsffi` on the executable this driver built, with the compiler it
            was built with
          '';
          description = ''
            The `ghc_wasm_jsffi.js` without which this target's binary
            cannot be instantiated. It is read out of the binary as linked,
            not out of `optimized`: the optimizer strips the sections the
            read needs. `null` for every target that is not wasm.
          '';
        };

      };

    # The fields of a compiler entry, shared by the native compiler and the
    # per-platform ones. Fields only one driver reads sit under that
    # driver's own key. Every default is literal, `null` or empty: what a
    # field falls back to depends on the driver (`name`) or on the package
    # (the rest), and each driver resolves it for itself, taking the field,
    # then the attribute the package carries, then a neutral value. A
    # default resolved here could not do that job. A driver's mirror seeds
    # every field of a submodule option as soon as one of them is defined,
    # which would freeze a single answer into both drivers.
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
          `package` set, the name selects the set whose compiler the package
          replaces. Set it only when the name derived from the version is
          not one the driver knows.
        '';
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = ''
          A compiler used directly instead of one from the driver's package
          sets: a bindist, an out-of-tree cross compiler, a locally built
          GHC. The sibling fields are spliced onto it, since both drivers
          read them off the compiler itself and a bindist generally carries
          none of them.
        '';
      };

      version = mkOption {
        type = types.nullOr types.str;
        default = null;
        defaultText = fromPackage "version" "the version in its name";
        example = "9.12.4.20260731";
        description = ''
          The compiler's version. Both drivers read it off the compiler, for
          paths and for `impl(ghc >= ...)` conditionals.

          Some builds cannot use the compiler package itself: the nixpkgs
          package set the project is built against, and haskell.nix's shell
          tools. These builds use the driver's stock compiler of the same
          major.minor.patch instead.

          Set this for a nightly bindist. A nightly's name carries only its
          series.
        '';
      };

      targetPrefix = mkOption {
        type = types.nullOr types.str;
        default = null;
        defaultText = fromPackage "targetPrefix" "the empty string";
        example = "wasm32-wasi-";
        description = ''
          The prefix on the compiler's executables. Both drivers invoke
          every tool by its prefixed name.
        '';
      };

      enableShared = mkOption {
        type = types.nullOr types.bool;
        default = null;
        defaultText = fromPackage "enableShared" "`true`";
        description = ''
          Whether the compiler can build shared libraries. The haskell.nix
          driver reads it for every component's `shared:` flag. The nixpkgs
          driver builds a cross package set non-static, with shared and not
          static libraries. GHC's wasm backend needs it, because its
          Template Haskell interpreter loads shared objects.
        '';
      };

      toolchain = mkOption {
        default = {};
        description = ''
          The C toolchain the compiler was configured with, when that is not
          the one the surrounding package set supplies. Everything built
          with the compiler is pointed back at it, since `Setup configure`'s
          foreign-dependency checks otherwise look in the wrong sysroot. The
          haskell.nix driver passes it as every package's configure flags.
          The nixpkgs driver makes it the cross package set's toolchain
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
                exporting `CC`, `AR` and the other tool variables is
                honored.
              '';
            };

          } // listToAttrs (map toolOption toolchainTools);
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
              defaultText = fromPackage "libDir" "the path haskell.nix derives from the version";
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
                built, on top of the ones the driver already takes from
                there. A package the compiler was configured against, but
                absent from the lists the driver copies out of it, belongs
                here. Without the entry, a build that needs the package
                finds nothing to depend on, and everything downstream of it
                breaks. One example: a compiler whose `text` is built
                against simdutf needs `system-cxx-std-lib` here.
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
              defaultText = fromPackage "haskellCompilerName" "`ghc-<version>`";
              example = "ghc-9.12.4.20260731";
              description = ''
                The compiler's cabal name. The driver names the package
                database directories of everything it builds after this
                name, and passes the name to cabal2nix as `--compiler`.
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
                external interpreter, which proxies them to the target over
                a socket. Set `false` for a compiler that runs splices
                itself, such as GHC's wasm backend. A target that has no
                sockets to proxy over needs `false`.
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
        package set for this system, and a cross target is named relative
        to it.
      '';
    };

    name = mkOption {
      type = types.nullOr types.str;
      default = if isPath config.src
        then baseNameOf config.src
        else getName config.src;
      defaultText = literalMD ''
        the base name of `src`
      '';
      description = ''
        Optional project name. It improves error messages, and the nixpkgs
        driver names the dev shell with it.
      '';
    };

    src = mkOption {
      type = types.either types.path types.package;
      example = "./.";
      description = ''
        The project source: the tree holding the cabal project file and the
        packages it names. A path is copied into the store, filtered first
        when `clean-src` is enabled. A derivation or a store path is used as
        it is, because whatever produced it already chose what it contains.
      '';
    };

    clean-src = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Filter `src` through the `.gitignore` it carries before copying it
        into the store. Build artifacts (`dist-newstyle`, `result`, `.git`)
        then do not become part of every derivation that names the project
        source, and a rebuild does not rehash them. Only applies when `src`
        is a path. A derivation is used as-is.
      '';
    };

    clean-src-ignore-files = mkOption {
      type = types.listOf types.str;
      default = [ "/.gitignore" ];
      description = ''
        The ignore files read when `clean-src` is enabled. Paths are
        relative to the root of the source tree.

        Every pattern uses the root as its base, whichever file it came
        from. An anchored pattern in a nested file (`dist/*`) therefore
        matches against the root, not against the file's own directory.
        Where that matters, add the pattern to `clean-src-patterns` instead.
      '';
      example = [ "/.gitignore" "/frontend/.gitignore" ];
    };

    clean-src-patterns = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra gitignore-syntax patterns, applied on top of the files
        `clean-src-ignore-files` names, when `clean-src` is enabled. A bare
        pattern (`dist-js`) matches at any depth. An anchored pattern read
        against the root cannot.
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
        `clean-src` is disabled. The project is built from this.
      '';
    };

    compiler = mkOption {
      default = {};
      description = ''
        The GHC to build with. `name` selects one of the driver's own
        compilers. `package` supplies one from outside them, and the sibling
        fields are the attributes the drivers read off a compiler.
        `platforms` gives cross targets their own compiler and toolchain. A
        platform without an entry uses the fields above it.

        Describe such a compiler once. The modules under
        `nix-haskell-compilers` are ready-made entries for compilers
        distributed outside the drivers' package sets.
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
            haskell-nix.extraNonReinstallablePkgs = [ "system-cxx-std-lib" ];
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

          # A mirror seeds submodule fields only one level deep, so a
          # per-driver definition under `compiler.platforms` replaces the
          # whole table for that driver.
          platforms = mkOption {
            type = types.attrsOf (types.submodule { options = compilerEntry; });
            default = {};
            description = ''
              Per-platform compilers, keyed by `pkgsCross` platform name
              (the keys of `shell.crossPlatforms` and `projectCross`). An
              entry has the same fields as the compiler above. The fields an
              entry leaves unset are resolved from its own `package`, not
              inherited. A per-driver definition anywhere under
              `compiler.platforms` replaces the whole table for that driver.
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
        Maps a url named in the cabal.project file to its source, so the
        source resolves without fetching. For a `source-repository-package`
        stanza, the entry's `.rev` attribute is checked against the
        stanza's `tag`.
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
        Hashes for the sources that `source-repository-package` stanzas in
        the cabal.project name. An alternative to `--sha256` comments in
        that file.

        Keys are stanza `location` URLs. Each value is an attribute set
        from the stanza's `tag` to the sha256 of the source. For a
        `repository` block, the value is the hash string itself.
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
      type =
        let platformPackageModule = platform: { config, name, ... }:
              let package = name;
                  entry = config;
                  exeBundles = exe: bundleFields { inherit platform package exe; };
              in {
                options.bundles = mkOption {
                  type = types.attrsOf (types.submodule ({ name, ... }:
                    { options = exeBundles name; }));
                  default = genAttrs (attrNames entry.components.exes) (_: {});
                  defaultText = literalMD ''
                    one entry per executable named under `components.exes`
                  '';
                  description = ''
                    What this package's executables are shipped as for this
                    target, keyed by the name each carries in
                    `components.exes`. The whole set can be read at once,
                    without naming each executable again.
                  '';
                };

                options.components = mkOption {
                  type = types.submodule {
                    options.exes = mkOption {
                      type = types.attrsOf (types.submodule ({ name, ... }:
                        { options.bundles = exeBundles name; }));
                    };
                  };
                };
              };

            # The package entry of the project-wide `packages` with what a
            # driver built for this target added to it, as a declaration merged
            # into the same submodule rather than a second copy of the fields.
            platformPackagesOption = platform: packages // {
              type = types.attrsOf (types.submoduleWith {
                shorthandOnlyDefinesConfig = true;
                modules = packages.type.nestedTypes.elemType.getSubModules ++ [
                  (platformPackageModule platform)
                ];
              });
              description = ''
                Per-package customization for this platform only, merged
                over the project-wide `packages`. The fields are the same,
                with `bundles` added: what a driver built for this target,
                in the form that ships.
              '';
            };

            platformModule = { name, ... }:
              let platform = name;
              in {
                options = {
                  packages = platformPackagesOption platform;
                  inherit (bundleOptimizerLayer) wasm-opt closure-compiler;
                };
              };

        in types.attrsOf (types.submodule platformModule);
      default = {};
      description = ''
        Per-platform customization, keyed by `pkgs.pkgsCross` platform name
        (the keys of `shell.crossPlatforms` and `projectCross`).

        A cabal file or project file can make a package's flags, and through
        them its dependencies, conditional on the platform. The haskell.nix
        driver follows those conditionals through its solver. The nixpkgs
        driver has no solver, so state here what the conditionals would have
        decided. The flags reach the point where a package's dependencies
        are computed, not only its configuration.

        `wasm-opt` and `closure-compiler` are the bundle optimizer settings
        for whatever is built for this target. The `packages` entries under
        them narrow a setting to one package, and their `components.exes`
        entries to one executable of it.
      '';
      example = fenced-code ''
        {
          wasi32.wasm-opt.level = "z";
          wasi32.packages.reflex-dom.flags.use-warp = false;
        }
      '';
    };

    packages = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          src = mkOption {
            type = types.nullOr (types.either types.path types.package);
            default = null;
            description = ''
              Replacement source for the package.
            '';
          };
          components = mkOption {
            type = types.submodule {
              options.exes = mkOption {
                type = types.attrsOf (types.submodule {
                  options = { inherit (bundleOptimizerLayer) wasm-opt closure-compiler; };
                });
                default = {};
                description = ''
                  Bundle optimizer settings for one executable of the
                  package, keyed by the name cabal gives it. They sit under
                  an executable rather than the package, because a bundle
                  belongs to one linked executable and a package can carry
                  several.

                  Naming an executable here also tells the haskell.nix
                  driver to install that executable's `.jsexe` directory,
                  which it otherwise leaves in the build tree.
                '';
              };
            };
            default = {};
            description = ''
              Per-component customization, grouped by the component kind
              cabal uses. Only executables carry anything so far.
            '';
          };
          inherit (bundleOptimizerLayer) wasm-opt closure-compiler;
        } // packageFields.options;
      });
      default = {};
      description = ''
        Per-package customization, keyed by cabal package name. Entries for
        packages that do not exist in the final package set are silently
        ignored, so platform-conditional packages can be customized
        unconditionally.
      '';
      example = fenced-code ''
        {
          splitmix.patches = [ ./splitmix-js.patch ];
          reflex-dom-core.doCheck = false;
          my-app.flags.production = true;
        }
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
                    if ! builtins.isString entry
                    then [ entry ]
                    else
                      let package = ps.${entry} or null;
                      in optional (package != null) package;

                  resolveAll = ps: concatMap (resolveEntry ps) (selection ps);

              in if selection == null
                 then null
                 else resolveAll;
            description = ''
              Package selection function. It takes a set of Haskell packages
              and returns a subset. The selected packages and all of their
              dependencies appear in `ghc-pkg list`.

              An entry is a package or a package name (a string). Use a name
              for a package whose availability depends on the platform.
            '';
            example = fenced-code ''
              ps: with ps; [
                common
                frontend
                "backend" # Provided by name so that it is only included when it's among `ps`
              ]
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
            example = fenced-code ''{ cabal = "latest"; haskell-language-server = "latest"; }'';
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
            defaultText = fenced-code ''ps: []'';
            description = ''
              Selects the cross-compilation targets, from an attribute set
              keyed by `pkgs.pkgsCross` platform names.
            '';
            example = fenced-code ''ps: with ps; [ ghcjs wasi32 ]'';
          };

        };
      };
    };



    source-repository-packages = mkOption {
      type = types.attrsOf (types.either types.path types.attrs);
      default = {};
      description = ''
        Local packages to add to the project. A source is anything `inputs`
        accepts. A packed thunk directory can be given as-is and resolves
        to the source it pins.

        `subdir` selects packages within the source, so a multi-package
        repository needs one entry rather than one per package.
      '';
      example = fenced-code ''
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
      '';
    };



    hackage-overlays = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = ''
        Packages to make visible to dependency resolution without being
        published to Hackage. One example is obelisk-generated-static.
      '';
      example = fenced-code ''
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
      '';
    };

  };



  config = {

    shell = {

      tools = {
        # This definition is re-applied inside each driver's mirror, where
        # it must stay below the seeds carrying the top-level values.
        cabal = mkDriverDefault "latest";
      };

    };

  };

}

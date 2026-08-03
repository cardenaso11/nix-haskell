# Driver-neutral project options.
#
# Every option in this module is honored by every driver: the totality check
# in tests/ compares these options against each driver's `translation` table,
# so adding an option here requires teaching all drivers about it. Anything
# only one backend can honor belongs in the driver's own module instead.

{ config, lib, pkgs, ... }:

with lib;

{

  options = {

    system = mkOption {
      type = types.str;
      default = builtins.currentSystem;
      defaultText = ''
        builtins.currentSystem
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

    clean-src-patterns = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra gitignore-syntax patterns applied on top of the tree's own
        `.gitignore` when `clean-src` is enabled. Useful for artifacts that only
        a nested `.gitignore` lists, since those patterns are not read.
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
               patterns = config.clean-src-patterns;
             }
        else config.src;
      defaultText = literalMD ''
      ```
        import ../libs/clean-source.nix { inherit pkgs; } {
          src = config.src;
          name = config.name;
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

    compiler-nix-name = mkOption {
      type = types.str;
      description = ''
        The name of the ghc compiler to use.
      '';
      example = "ghc884";
      default = "ghc914";
      defaultText = "ghc914";
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
        cabal = mkDefault "latest";
      };

    };

  };

}

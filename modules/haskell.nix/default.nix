# The haskell.nix driver, assembled from the fragment files beside this
# one. Each fragment is a pure function over the context it needs.
#
# Everything haskell.nix-specific lives under the `haskell-nix` namespace:
#
# - project options, set through `haskell-nix.options`
# - driver conveniences (`overrides`, `extraCabalProject`,
#   `extraSrcFiles`), directly under `haskell-nix`
# - `haskell-nix.translation`, recording how every common option maps onto
#   haskell.nix
#
# The translation table populates `haskell-nix.options`, and every common
# option needs an entry in it, or evaluation fails.

{ config, options, lib, pkgs, system, ... }:

with lib;
with (import ../../libs/prelude { inherit lib; });

let cfg = config."haskell-nix";

    # The common options, re-declared under this driver's namespace and
    # seeded from the top-level values, so setting
    # `haskell-nix.packages.foo.flags` overrides the common value for this
    # driver only. The driver reads all common configuration through the
    # mirror.
    common = import ../../libs/driver/common.nix {
      inherit lib pkgs cfg;
      driver = "haskell.nix";
      topConfig = config;
      topOptions = options;
    };

    compilers = common.compilers;
    compiler = compilers.native;

    srpStanzaLines = cfg.stages.source-repository-packages.cabalProject;

    # haskell.nix builds shell tools in their own projects, keyed only by
    # `compiler-nix-name` (default selection: `haskell-nix.compiler.<name>`).
    # A compiler package's own name is generally absent there, so the driver
    # pins tools to its compiler of the same version instead. Priority
    # 1099: above haskell.nix's own injection (1100), below user definitions.
    # A tool spec is a version string, a module, or a list of modules.
    toolModules = spec:
      if isString spec then [ { version = spec; } ]
      else if isList spec then spec
      else [ spec ];
    withToolCompiler = spec:
      if compiler.package == null then spec
      else toolModules spec ++ [ { compiler-nix-name = mkOverride 1099 compiler.stockName; } ];

in {

  options."haskell-nix" = common.options
    // common.interface (import ./interface.nix { inherit lib cfg compiler; })
    // import ./input.nix { inherit lib config system; }
    // {

      default-compiler = mkOption {
        type = types.str;
        default = "ghc914";
        description = ''
          The `compiler.name` this driver falls back to when no
          `compiler.package` is set. A project's own `compiler.name`
          overrides it.
        '';
        example = "ghc910";
      };

      overrides = mkOption {
        type = types.listOf types.unspecified;
        default = [];
        description = ''
          haskell.nix `modules` to add to the project. Use it for anything
          the common options do not cover. Two definitions concatenate
          rather than replace one another.
        '';
        example = fenced-code ''[ { packages.my-dep.flags.debug = true; } ]'';
      };

      extraSrcFiles = mkOption {
        type = types.attrs;
        default = {};
        description = ''
          Files from the project source to add to component builds, in
          haskell.nix's `extraSrcFiles` shape: `library.extraSrcFiles`,
          `exes.<name>.extraSrcFiles`, and so on.
        '';
        example = { library.extraSrcFiles = [ "static/style.css" ]; };
      };

      project = mkOption {
        default =
          let p = config.haskell-nix.haskell-nix.project config.haskell-nix.options;
              shellWithHooks = p.shell.overrideAttrs (old: {
                shellHook = old.shellHook + cfg.shell.shellHook;
                withHoogle = old.withHoogle or cfg.shell.withHoogle;
              });
          in p // { shell = shellWithHooks; };
        defaultText = fenced-code ''config.haskell-nix.haskell-nix.project config.haskell-nix.options'';
        description = ''
          The built project as haskell.nix returns it: `hsPkgs`, `shell`,
          `projectCross` per cross platform, `plan-nix`, and the rest. The
          shell is haskell.nix's own, with the common `shell.shellHook`
          appended and `shell.withHoogle` applied. Both go through
          `overrideAttrs`, so neither is evaluated unless the shell is.
        '';
        type = types.raw;
      };

    }
    // import ./stages.nix { inherit lib pkgs config cfg srpStanzaLines; }
    // import ./translation.nix {
         inherit lib pkgs config cfg compiler compilers srpStanzaLines withToolCompiler;
       }
    // import ./project-options.nix { inherit lib config cfg; };

  config = mkMerge (common.mirror-config {
    namespace = "haskell-nix";
    defaultCompiler = cfg.default-compiler;
  } ++ [

    {
      haskell-nix.options = mkMerge (
        [
          { hsPkgs = mkDefault null; }
          { modules = cfg.overrides; }
          (mkIf (cfg.extraSrcFiles != {}) {
            modules = [ { packages.${cfg.name}.components = cfg.extraSrcFiles; } ];
          })
        ]
        ++ map (t: mkIf (t.set != null) t.set) (attrValues cfg.translation)
      );
    }

    {
      # The hoogle version haskell.nix can build against ghc 9.14. This
      # definition lands past `shell.tools`, so it re-applies the
      # tool-compiler pin.
      haskell-nix.options.shell.tools.hoogle = mkDefault (withToolCompiler {
        version = "5.0.19.0";
        cabalProjectLocal = ''
          if impl(ghc == 9.14.*)
            allow-newer:
                *:base
              , *:template-haskell
              , *:ghc-experimental
              , *:ghc-internal
              , *:containers
            constraints:
                base < 4.23
              , template-haskell < 2.25
              , ghc-experimental < 9.1500
              , ghc-internal < 9.1500
        '';
      });
    }

  ]);

}

# Changelog

## Unreleased

### Added

- A `nixpkgs` driver: builds the project with the Haskell infrastructure of
  nixpkgs (`haskell.packages.<compiler>`, `callCabal2nix`, `shellFor`).
  Driver knobs live under `nixpkgs.options`. The result is at
  `(nix-haskell m).nixpkgs.project` and `project.nixpkgs`. `compiler`
  defaults to `ghc912` for this driver.
- Driver-neutral common options `ghcOptions`, `cabalProject`,
  `cabalProjectLocal`, `cabalProjectFileName`, `extraCabalProject`,
  `inputMap`, `sha256map` and `packages.<name>.*`:
  `flags`, `patches`, `ghcOptions`, `configureFlags`, `setupBuildFlags`,
  `setupHaddockFlags`, `doCheck`, `doHaddock`, `doCoverage`, `doHoogle`,
  `doHyperlinkSource`, `doQuickjump`, `dontStrip`,
  `enableDeadCodeElimination`, `enableLibraryProfiling`, `enableProfiling`,
  `profilingDetail`, `enableShared`, `enableStatic`,
  `enableSeparateDataOutput`, `enableLibraryForGhci`, `hardeningDisable`,
  `src` and the phase hooks (`preUnpack` through `postInstall`).
- `clean-src-ignore-files`, the ignore files read when `src` is filtered.
  Only the tree's own `.gitignore` was read before, and a nested one could
  not be named.
- A per-driver `translation` table (internal) recording how every common
  option is honored, and flake `checks`:
  `translation-totality`, `every-option-<driver>`, `hello-<driver>`.
- The common options are mirrored under each driver namespace, seeded from
  the project-wide values, so any common option can be overridden for one
  driver only (e.g. `nixpkgs.packages.<name>.flags`).
- `examples/hello`, buildable with both drivers.
- Compilers from outside the drivers' package sets, described by the
  `compiler` option: a bindist or cross toolchain, with the attributes the
  drivers read off a compiler, and the C toolchain it was configured with.
  Everything built with such a compiler is pointed at that toolchain. The
  haskell.nix driver passes the toolchain as configure flags and attaches
  `cachedDeps` to a compiler package. The nixpkgs driver builds a cross
  package set whose toolchain it is, through `replaceCrossStdenv`.
- `nixpkgs.pkgsCross`, the cross package sets `projectCross` builds from.
- `nixpkgs.options.cross-package-defaults`, what is relaxed for every
  package of a cross set the driver builds itself: version bounds,
  documentation and profiling libraries. Tests and benchmarks are not among
  them, since nothing in such a set can run what it builds.
- `platforms.<platform>.packages`, per-package customization for one cross
  platform, merged over the project-wide `packages`. It expresses a cabal
  file's platform conditional for the nixpkgs driver, which has no solver
  to follow one. The flags reach the point where a package's dependencies
  are computed, so a backend the target cannot build is never depended on.
  The haskell.nix driver applies an entry in the project whose target is
  that platform.
- Bundle optimizers, for what a driver hands back from a cross build: a
  wasm binary through `wasm-opt` plus a strip of its custom sections, a
  `.jsexe` through closure-compiler, and the `ghc_wasm_jsffi.js` that
  `post-link.mjs` reads out of a wasm binary. The flags are the tools' own,
  under `wasm-opt` and `closure-compiler`. Five layers can state them, from
  one executable of a package on one cross target down to the tool's own
  defaults. `wasm-optimize`, `js-optimize` and `wasm-jsffi` apply them to
  an artifact named directly.
- `platforms.<platform>.packages.<package>.bundles` and the same under
  `components.exes.<exe>`: the artifact a driver built for that target,
  optimized, with its jsffi bindings beside it. Read through a driver,
  which is the only thing that knows what it built.
- `<driver>.cross-compiler` and `<driver>.cross-exe`, the compiler a driver
  builds a cross target with and what it builds an executable into. Nothing
  then needs to know that one driver keeps components under
  `hsPkgs.<package>.components.exes.<exe>` and the other one derivation per
  package. `<driver>.compiler-version` answers what each builds against.
  That is not always the same compiler: the drivers mirror `compiler`
  separately and fall back to different ones of their own.
- `nixpkgs.options.exact-configuration`: tell Cabal every direct dependency
  and every flag, so it resolves nothing itself and reads no version bound.
  Without it, this driver enforces bounds written before the compiler in
  hand, and `jailbreak` cannot lift one stated inside a conditional stanza.
- `packages.<name>.components.exes.<exe>`, which carries an executable's
  own optimizer settings and, for the haskell.nix driver, installs its
  `.jsexe` beside the bundled `bin/<exe>` that driver installs on its own.
  The nixpkgs builder copies the directory out already.
- `modules/compilers`, imported like `modules/patches` through the
  `nix-haskell-compilers` argument, with `ghc-wasm-meta` as its first
  entry: ghc-wasm-meta's wasm GHC and wasi-sdk, keyed on a GHC series.
- A `ghc-wasm-meta` pin, and `haskell-nix-wasm-meta` / `nixpkgs-wasm-meta`
  outputs in `examples/reflex-todomvc` building the wasm target with its
  GHC 9.12 bindist through either driver.
- Wasm cross tools in the nixpkgs driver's shell, so
  `nixpkgs.shell.crossPlatforms` takes a wasm target as well as a
  javascript one. The driver builds the wrapped cross compiler itself,
  because nixpkgs' `ghcWithPackages` cannot wrap a relocatable bindist. The
  package database stays where the compiler keeps it.

### Changed (breaking)

- `compiler-nix-name` is now the `compiler` submodule: `compiler.name` for
  one of the driver's own compilers, `compiler.package` and the fields
  around it for one from outside them, and `compiler.platforms.<platform>`
  for a cross target's own. Fields only one driver reads sit under that
  driver's key (`compiler.haskell-nix.{libDir,extraNonReinstallablePkgs}`,
  `compiler.nixpkgs.{haskellCompilerName,enableExternalInterpreter}`). The
  `nixpkgs.compiler` escape hatch is the mirror of the same option.
- Driver defaults of common options now sit between the mirror seeds and
  the declaration defaults, so a project-wide definition reaches every
  driver. Before, the nixpkgs driver's `ghc912` default silently beat a
  top-level `compiler-nix-name`, and the mirrors reverted a top-level
  `shell.tools.cabal` to `latest`.
- A driver's mirror now seeds only the fields the project defined. A driver
  default therefore reaches every field the project left alone, at any
  depth. Before, defining one field of a submodule option seeded the whole
  submodule, which defeated driver defaults on its other fields and set
  read-only sub-options twice.
- The result attrset: `(nix-haskell m).nixpkgs` is now the nixpkgs driver.
  The raw package set moved to `(nix-haskell m).pkgs`.
- haskell.nix-specific options moved under the driver namespace, without
  aliases. See the migration table in the README:
  - `overrides` and `extraSrcFiles` are now `haskell-nix.<same>`.
  - `cabalProjectFreeze`, `index-state`, `extra-hackages`,
    `extra-hackage-tarballs`, `pkg-def-extras` are now
    `haskell-nix.options.<same>`.
  - haskell.nix-only shell options (`withHaddock`, `exactDeps`, ...) are
    now `haskell-nix.options.shell.<same>`.
- The common `shell` submodule is declared natively (no longer typed by
  haskell.nix's shell module): `packages`, `tools`, `buildInputs`,
  `nativeBuildInputs`, `shellHook`, `withHoogle`, `crossPlatforms`.
  `shell.withHoogle` now defaults to `false`.
- `modules/patches/*` are functions over an optional `drivers` list
  selecting the drivers the patch applies to. null (the default) applies it
  to all.
- The `optimizations` module writes the common `ghcOptions` option.
- The generated manual no longer documents haskell.nix's per-package
  `modules.*` option tree. Those options are set through
  `haskell-nix.overrides` and documented by haskell.nix itself.
- The `nixpkgs` pin is a nix-thunk instead of a git submodule.

### Removed

- The `reflex-platform` pin, flake input, and planned driver.

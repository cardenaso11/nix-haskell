# Changelog

## Unreleased

### Added

- A `nixpkgs` driver: builds the project with the Haskell infrastructure of
  nixpkgs (`haskell.packages.<compiler>`, `callCabal2nix`, `shellFor`).
  Driver knobs live under `nixpkgs.options`; the result is at
  `(nix-haskell m).nixpkgs.project` and `project.nixpkgs`.
  `compiler` defaults to `ghc912` for this driver.
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
- A per-driver `translation` table (internal) recording how every common
  option is honored, and flake `checks`:
  `translation-totality`, `every-option-<driver>`, `hello-<driver>`.
- The common options are mirrored under each driver namespace, seeded from
  the project-wide values, so any common option can be overridden for one
  driver only (e.g. `nixpkgs.packages.<name>.flags`).
- `examples/hello`, buildable with both drivers.
- Compilers from outside the drivers' package sets, described by the
  `compiler` option: a bindist or cross toolchain, with the attributes the
  drivers read off a compiler, and the C toolchain it was configured with,
  which everything built with it is then pointed at. Both drivers grew the
  machinery: haskell.nix gives every package the toolchain's configure flags
  and a compiler package `cachedDeps`, without which every boot package
  reaches `Setup configure` unresolved; the nixpkgs driver builds a cross
  package set whose own toolchain it is, through `replaceCrossStdenv`.
- `nixpkgs.pkgsCross`, the cross package sets `projectCross` builds from.
- `modules/compilers`, imported like `modules/patches` through the
  `nix-haskell-compilers` argument, with `ghc-wasm-meta` as its first entry:
  ghc-wasm-meta's wasm GHC and wasi-sdk, keyed on a GHC series.
- A `ghc-wasm-meta` pin, and `haskell-nix-wasm-meta` / `nixpkgs-wasm-meta`
  outputs in `examples/reflex-todomvc` building the wasm target with its GHC
  9.12 bindist through either driver.

### Changed (breaking)

- `compiler-nix-name` is now the `compiler` submodule: `compiler.name` for one
  of the driver's own compilers, `compiler.package` and the fields around it
  for one from outside them, and `compiler.platforms.<platform>` for a cross
  target's own. Fields only one driver reads sit under that driver's key
  (`compiler.haskell-nix.libDir`,
  `compiler.nixpkgs.{haskellCompilerName,enableExternalInterpreter}`), and the
  `nixpkgs.compiler` escape hatch is the mirror of the same option.
- Driver defaults of common options now sit between the mirror seeds and
  the declaration defaults, so a project-wide definition reaches every
  driver: previously the nixpkgs driver's `ghc912` default silently beat a
  top-level `compiler-nix-name`, and the mirrors reverted a top-level
  `shell.tools.cabal` to `latest`.
- A driver's mirror seeds only what the project defined, down to the field, so
  a driver default reaches every field the project left alone however deeply
  nested. Seeding the whole of a submodule option, as it did before, defeated
  driver defaults on all of its fields as soon as one was defined, and set
  read-only sub-options twice.
- The result attrset: `(nix-haskell m).nixpkgs` is now the nixpkgs driver;
  the raw package set moved to `(nix-haskell m).pkgs`.
- haskell.nix-specific options moved under the driver namespace, without
  aliases. See the migration table in the README:
  `overrides` and `extraSrcFiles` are now `haskell-nix.<same>`;
  `cabalProjectFreeze`, `index-state`, `extra-hackages`,
  `extra-hackage-tarballs`, `pkg-def-extras` are now
  `haskell-nix.options.<same>`; haskell.nix-only shell options
  (`withHaddock`, `exactDeps`, ...) are now `haskell-nix.options.shell.<same>`.
- The common `shell` submodule is declared natively (no longer typed by
  haskell.nix's shell module): `packages`, `tools`, `buildInputs`,
  `nativeBuildInputs`, `shellHook`, `withHoogle`, `crossPlatforms`.
  `shell.withHoogle` now defaults to `false`.
- `modules/patches/*` are functions over an optional `drivers` list
  selecting the drivers the patch applies to; null (the default) applies it
  to all.
- The `optimizations` module writes the common `ghcOptions` option.
- The generated manual no longer documents haskell.nix's per-package
  `modules.*` option tree; those options are set through
  `haskell-nix.overrides` and documented by haskell.nix itself.
- The `nixpkgs` pin is a nix-thunk instead of a git submodule.

### Removed

- The `reflex-platform` pin, flake input, and planned driver.

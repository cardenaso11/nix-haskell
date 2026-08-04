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

### Changed (breaking)

- `compiler-nix-name` is now `compiler`, and accepts a compiler package
  besides a name: a bindist or cross compiler (e.g. the wasm toolchains of
  ghc-wasm-meta), used by the drivers directly. Either form can also be
  given per platform, as an attrset keyed by the native system and
  `pkgsCross` names. The `nixpkgs.compiler` escape hatch is subsumed by
  the mirrored common option of the same name.
- Driver defaults of common options now sit between the mirror seeds and
  the declaration defaults, so a project-wide definition reaches every
  driver: previously the nixpkgs driver's `ghc912` default silently beat a
  top-level `compiler-nix-name`, and the mirrors reverted a top-level
  `shell.tools.cabal` to `latest`.
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

# Changelog

## Unreleased

### Added

- A `nixpkgs` driver: builds the project with the Haskell infrastructure of
  nixpkgs (`haskell.packages.<compiler>`, `callCabal2nix`, `shellFor`).
  Driver knobs live under `nixpkgs.options`; the result is at
  `(nix-haskell m).nixpkgs.project` and `project.nixpkgs`.
- Driver-neutral common options `ghcOptions` and `packages.<name>.{flags,
  patches, ghcOptions, doCheck, doHaddock, src}`.
- A per-driver `translation` table (internal) recording how every common
  option is honored, and flake `checks`:
  `translation-totality`, `every-option-<driver>`, `hello-<driver>`.
- `examples/hello`, buildable with both drivers.

### Changed (breaking)

- The result attrset: `(nix-haskell m).nixpkgs` is now the nixpkgs driver;
  the raw package set moved to `(nix-haskell m).pkgs`.
- haskell.nix-specific options moved under the driver namespace, without
  aliases. See the migration table in the README:
  `overrides`, `extraCabalProject`, `extraSrcFiles` are now
  `haskell-nix.<same>`; `cabalProject*`, `index-state`, `sha256map`,
  `inputMap`, `extra-hackages`, `extra-hackage-tarballs`, `pkg-def-extras`
  are now `haskell-nix.options.<same>`; haskell.nix-only shell options
  (`withHaddock`, `exactDeps`, ...) are now `haskell-nix.options.shell.<same>`.
- The common `shell` submodule is declared natively (no longer typed by
  haskell.nix's shell module): `packages`, `tools`, `buildInputs`,
  `nativeBuildInputs`, `shellHook`, `withHoogle`, `crossPlatforms`.
  `shell.withHoogle` now defaults to `false`.
- `modules/patches/*` write the common `packages.<name>.patches` option and
  therefore apply to both drivers.
- The `optimizations` module writes the common `ghcOptions` option.
- The generated manual no longer documents haskell.nix's per-package
  `modules.*` option tree; those options are set through
  `haskell-nix.overrides` and documented by haskell.nix itself.

### Removed

- The `reflex-platform` pin, flake input, and planned driver.

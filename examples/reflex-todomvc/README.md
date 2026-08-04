# TodoMVC in Reflex

All of the code lives in `src/Reflex/TodoMVC.hs`.
`static/style.css` is embedded into the application.

## Build Instructions

The driver is the first `-A` attribute (`haskell-nix` or `nixpkgs`):

```bash
nix-build -A haskell-nix.projectCross.wasi32.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc
```

```bash
nix-build -A haskell-nix.projectCross.ghcjs.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc
```

```bash
nix-build -A nixpkgs.packages.reflex-todomvc
```

Then open `index-wasm.html` (wasm) or `index-js.html` (GHCJS) in your
browser!

### With an out-of-tree compiler

The `-wasm-meta` attributes build the wasm target with the GHC 9.12 bindist
of the `ghc-wasm-meta` pin instead of the drivers' own compilers, through
the `compiler` option's package form:

```bash
nix-build -A haskell-nix-wasm-meta.projectCross.wasi32.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc
```

```bash
nix-build -A nixpkgs-wasm-meta.packages.reflex-todomvc
```

or through the flake: `nix build .#haskell-nix-wasm-meta` /
`nix build .#nixpkgs-wasm-meta`.

The bindist is configured with its own wasi-sdk C toolchain rather than the
cross package set's, so the components are pointed back at it; without that,
`Setup configure`'s C checks look in the wrong sysroot. For the haskell.nix
driver that is per-package `configureFlags`; for the nixpkgs driver the sdk
becomes the cross toolchain outright, through `replaceCrossStdenv`.

Both drivers need shared libraries, since GHC's wasm Template Haskell
interpreter loads `.so`s: haskell.nix forces `shared: True` itself, and the
nixpkgs set turns `isStatic` off. The nixpkgs driver additionally has to be
kept off `iserv-proxy`, the socket-based external interpreter it would
otherwise proxy Template Haskell through, which cannot work on WASI.

Note that `nixpkgs-wasm-meta` builds through the driver's own `packages`, not
`projectCross`: its whole package set is already the wasm one.

## Shell

The same `-A` choice selects the shell's driver:

```bash
nix-shell -A haskell-nix
nix-shell -A nixpkgs
```

or through the flake: `nix develop` / `nix develop .#nixpkgs`.

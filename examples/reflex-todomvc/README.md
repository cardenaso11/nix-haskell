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

The `-wasm-meta` attributes build the wasm target with the GHC 9.12 bindist of
the `ghc-wasm-meta` pin instead of the drivers' own compilers:

```bash
nix-build -A haskell-nix-wasm-meta.projectCross.wasi32.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc
```

```bash
nix-build -A nixpkgs-wasm-meta.projectCross.wasi32.packages.reflex-todomvc
```

or through the flake: `nix build .#haskell-nix-wasm-meta` /
`nix build .#nixpkgs-wasm-meta`.

`default.nix` asks for the compiler by importing
`nix-haskell-compilers/ghc-wasm-meta`, which describes the bindist and the
wasi-sdk it was configured with; what each driver then does with a compiler
like that is the library's business. The one thing left to the project is a
flag: `project.nix` assigns the flags of a `!arch(wasm32)` stanza for the
nixpkgs driver, which cannot read them, and the warp backend they select
brings in C libraries that nixpkgs cannot cross-compile to wasi.

## Shell

The same `-A` choice selects the shell's driver:

```bash
nix-shell -A haskell-nix
nix-shell -A nixpkgs
```

or through the flake: `nix develop` / `nix develop .#nixpkgs`.

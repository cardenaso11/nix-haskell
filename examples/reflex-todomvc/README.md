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

Then open `index.html` in your browser!

## Shell

The same `-A` choice selects the shell's driver:

```bash
nix-shell -A haskell-nix
nix-shell -A nixpkgs
```

or through the flake: `nix develop` / `nix develop .#nixpkgs`.

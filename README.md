## Nix-Haskell

A NixOS-style module system for building Haskell projects with [haskell.nix](https://github.com/input-output-hk/haskell.nix). Provides declarative configuration for compilers, dependencies, cross-compilation, and development shells.

> **Note:** Currently only the `haskell.nix` driver is implemented. Support for other drivers (e.g. `nixpkgs` haskellPackages, `cabal2nix`, `reflex-platform`) is planned.


### Quick start

```nix
let nix-haskell = import ./deps/nix-haskell {};
in nix-haskell { src = ./.; }
```

The result is an attribute set:

```nix
{
  config       # Evaluated module configuration
  nixpkgs      # The nixpkgs package set
  haskell-nix  # haskell.nix project builder (with .override support)
  project      # Convenience aliases (project.haskell-nix)
  manual       # Documentation (manual.man, manual.md, manual.view)
}
```


### Flake usage

```nix
{
  inputs.nix-haskell.url = "github:reflex-frp/nix-haskell";

  outputs = { nix-haskell, ... }:
    let lib = nix-haskell.lib.x86_64-linux;
        project = lib.nix-haskell ./project.nix;
    in {
      packages.x86_64-linux.default = project.haskell-nix.project;
    };
}
```

All attributes from `default.nix` are available as functions in `lib.<system>`:

```nix
lib.config module       # (nix-haskell module).config
lib.haskell-nix module  # (nix-haskell module).haskell-nix
lib.manual module       # (nix-haskell module).manual
# etc.
```


### Module options

#### Project

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | `nullOr str` | from `src` | Project name |
| `src` | `path` | — | Project source directory |
| `system` | `str` | `builtins.currentSystem` | Build system |
| `compiler-nix-name` | `str` | `"ghc914"` | GHC compiler version |

#### Cabal configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `source-repository-packages` | `attrsOf (path \| attrs)` | `{}` | Local packages to include |
| `extraCabalProject` | `listOf lines` | `[]` | Lines appended to `cabal.project` |
| `index-state` | `nullOr str` | `null` | Hackage index snapshot |
| `inputMap` | `attrs` | `{}` | URL to local source mappings |
| `sha256map` | `nullOr attrs` | `null` | SHA256 map for cabal sources |

`source-repository-packages` accepts either a path or an attrset with `src` and optional `condition`:

```nix
source-repository-packages = {
  reflex-dom = deps.reflex-dom + "/reflex-dom";
  obelisk-backend = {
    src = deps.obelisk + "/lib/backend";
    condition = "!arch(javascript)";
  };
};
```

#### Extra source files

```nix
extraSrcFiles = {
  library.extraSrcFiles = [ "static/style.css" ];
  exes.my-app.extraSrcFiles = [ "static/style.css" ];
};
```

#### Hackage overlays

Make custom packages visible to the cabal solver:

```nix
hackage-overlays = [
  {
    name = "my-package";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub { ... };
  }
];
```

#### Overrides

haskell.nix module overrides. Lists are concatenated when composed (not replaced):

```nix
overrides = [
  ({ pkgs, lib, ... }: {
    enableDeadCodeElimination = true;
    packages = {
      obelisk-command.components.library.build-tools = with pkgs; [ ghcid jre openssh ];
      reflex-dom-core.components.tests.gc.buildable = lib.mkForce false;
    };
  })
];
```

#### Shell

```nix
shell = {
  crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
  packages = ps: with ps; [ common frontend "backend" ];
  tools = { cabal = "latest"; };
  withHaddock = false;
  withHoogle = false;
};
```

When GHCJS is in `crossPlatforms`, Node.js is automatically added to `buildInputs`.

#### haskell.nix options

Pass options directly to the underlying haskell.nix project:

```nix
haskell-nix.options = {
  # haskell.nix specific configuration
};
```


### Inputs

Dependencies live under `inputs`, one entry per submodule in `pins/`. An entry
accepts whatever a flake input can be: a flake input, a store path, a checkout,
or a packed thunk.

```nix
{
  inputs.haskell-nix = ./dep/your-haskell-nix;
  inputs.reflex-platform = inputs.reflex-platform;   # a flake input
}
```

The submodules in `pins/` supply `nixpkgs`, `haskell-nix` and `reflex-platform`.
Entries of your own can be added freely, and are resolved the same way.

Flake inputs are picked up automatically, so `inputs.nixpkgs` follows the
consuming flake's `nixpkgs` without any wiring. Precedence runs
`pins/` < flake inputs < whatever you set explicitly.


### Override

The `haskell-nix.project` output supports `.override` for composing additional configuration:

```nix
let project = (nix-haskell ./project.nix).haskell-nix.project;
in project.override (inputs: {
  overrides = [
    ({ pkgs, ... }: {
      packages.my-pkg.components.library.build-tools = [ pkgs.zlib ];
    })
  ];
})
```

Overrides use recursive merge — lists are concatenated, attrsets are merged recursively.


### Full example

```nix
{ nix-haskell-patches, ... }:

{
  imports = [
    "${nix-haskell-patches}/js/splitmix"
  ];

  name = "reflex-todomvc";
  src = ./.;
  compiler-nix-name = "ghc914";

  source-repository-packages = {
    reflex-dom = {
      src = ./deps/reflex-dom;
      subdir = [ "reflex-dom" "reflex-dom-core" ];
    };
  };

  extraSrcFiles = {
    library.extraSrcFiles = [ "static/style.css" ];
    exes.reflex-todomvc.extraSrcFiles = [ "static/style.css" ];
  };

  shell = {
    crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
    packages = ps: with ps; [ reflex-todomvc ];
    withHaddock = false;
    withHoogle = false;
  };
}
```


### Modules documentation

```
nix run --no-write-lock-file github:reflex-frp/nix-haskell#manual-view
```

or [docs/modules.md](docs/modules.md)

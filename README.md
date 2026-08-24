## Nix-Haskell

A NixOS-style module system for building Haskell projects. One declarative
project configuration drives interchangeable build backends ("drivers"):

- **haskell.nix**: [IOG's haskell.nix](https://github.com/input-output-hk/haskell.nix).
  Full cabal solving against a pinned Hackage, per-component builds,
  first-class cross-compilation.
- **nixpkgs**: the Haskell infrastructure of nixpkgs
  (`haskell.packages.<compiler>`, `callCabal2nix`, `shellFor`). No solver;
  dependency versions come from the nixpkgs package set, and most of the
  dependency closure comes straight from cache.nixos.org.

Every option of the common module is honored by every driver; a check
enforces that totality (see [Checks](#checks)). Driver-specific
configuration lives under the driver's own namespace (`haskell-nix.*`,
`nixpkgs.*`).

The common options are also mirrored under each driver's namespace, seeded
with the project-wide values: a definition there overrides the common value
for that driver only.

```nix
packages.reflex-dom.flags.webkit2gtk = false;          # both drivers
nixpkgs.packages.reflex-dom.flags.webkit2gtk = false;  # nixpkgs driver only
```


### Quick start

```nix
let nix-haskell = import ./deps/nix-haskell {};
in nix-haskell { src = ./.; }
```

The result is an attribute set:

```nix
{
  config           # Evaluated module configuration
  pkgs             # The nixpkgs package set of the evaluation
  haskell-nix      # haskell.nix driver (.project, .ghcWithPackages)
  nixpkgs          # nixpkgs driver (.project, .ghcWithPackages)
  project          # Per-driver projects (project.haskell-nix, project.nixpkgs)
  ghcWithPackages  # Per-driver ghcWithPackages
  manual           # Documentation (manual.man, manual.md, manual.view)
}
```

Both projects support `.override` for composing additional configuration:

```nix
let project = (nix-haskell ./project.nix).nixpkgs.project;
in project.override { ghcOptions = [ "-O2" ]; }
```

Overrides use recursive merge: lists are concatenated, attrsets are merged
recursively.


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
lib.nixpkgs module      # (nix-haskell module).nixpkgs
# etc.
```


### Common options

Applicable to every driver. The full reference is in the
[manual](docs/modules.md).

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | `nullOr str` | from `src` | Project name |
| `src` | `path` | — | Project source directory |
| `system` | `str` | `builtins.currentSystem` | Build system |
| `compiler` | `submodule` | the driver's own | GHC to build with: a name, a package from outside the driver's sets, per platform |
| `clean-src` | `bool` | `true` | Filter `src` through its `.gitignore` |
| `clean-src-ignore-files` | `listOf str` | `[ "/.gitignore" ]` | Ignore files to read, relative to the tree root |
| `clean-src-patterns` | `lines` | `""` | Extra gitignore patterns |
| `ghcOptions` | `listOf str` | `[]` | Project-wide GHC flags |
| `cabalProject` | `nullOr lines` | `null` | `cabal.project` content (replaces the file) |
| `cabalProjectLocal` | `nullOr lines` | `null` | `cabal.project.local` content |
| `cabalProjectFileName` | `str` | `"cabal.project"` | Name of the project file |
| `extraCabalProject` | `listOf lines` | `[]` | Lines appended to `cabal.project` |
| `inputMap` | `attrs` | `{}` | URL to source mappings |
| `sha256map` | `nullOr attrs` | `null` | Hashes for sources named in `cabal.project` |
| `packages` | `attrsOf submodule` | `{}` | Per-package customization |
| `platforms` | `attrsOf submodule` | `{}` | Per-package customization for one cross platform only |
| `source-repository-packages` | `attrsOf (path \| attrs)` | `{}` | Local packages to include |
| `hackage-overlays` | `listOf attrs` | `[]` | Packages not on Hackage |
| `shell` | `submodule` | | Development shell |
| `optimizations` | `submodule` | off | GHC optimization flag presets |
| `wasm-opt` | `submodule` | `-O2`, shrunk | What wasm-opt does to a built wasm binary |
| `closure-compiler` | `submodule` | `ADVANCED` | What closure-compiler does to a built jsexe |
| `inputs` | `attrsOf raw` | `pins/` | Dependency sources |

#### Compiler

Naming one of the driver's own compilers is all most projects need:

```nix
compiler.name = "ghc912";
```

A compiler from outside those package sets, such as a bindist or a cross
toolchain, is given as a package instead. Both drivers read a handful of
attributes off a compiler that a bindist does not carry, so they are given
alongside it, and `toolchain` names the C tools it was configured with, which
everything built with it is then pointed at:

```nix
compiler.platforms.wasi32 = {
  package = wasm-ghc;
  version = "9.12.4.20260731";
  targetPrefix = "wasm32-wasi-";
  enableShared = true;
  haskell-nix.libDir = "lib";
  nixpkgs.enableExternalInterpreter = false;
  toolchain = {
    package = wasi-sdk;
    cc = "wasm32-wasi-clang";
    ar = "llvm-ar";
    ld = "wasm-ld";
    strip = "llvm-strip";
  };
};
```

| Field | Read by | Meaning |
|-------|---------|---------|
| `name` | both | The compiler's name in the driver's package sets, and the name packages are pinned under |
| `package` | both | A compiler used directly instead of one of the driver's |
| `version` | both | Its version, and the release whose package set and shell tools stand in for what cannot be built with it |
| `targetPrefix` | both | The prefix its executables carry |
| `enableShared` | both | Whether it builds shared libraries |
| `toolchain` | both | The C tools it was configured with (`package`, `cc`, `ar`, `ld`, `strip`) |
| `haskell-nix.libDir` | haskell.nix | Where its package database and `settings` live, relative to its store path |
| `haskell-nix.extraNonReinstallablePkgs` | haskell.nix | Packages taken from its own database rather than built, on top of the usual ones |
| `nixpkgs.haskellCompilerName` | nixpkgs | Its cabal name, which names package database directories and is cabal2nix's `--compiler` |
| `nixpkgs.enableExternalInterpreter` | nixpkgs | Whether Template Haskell splices are proxied to the target |

`platforms` is keyed by `pkgs.pkgsCross` platform name, the same keys
`shell.crossPlatforms` and `projectCross` use. An entry is additive: a platform
without one uses the compiler above the table, and the fields an entry leaves
unset are resolved from its own `package` rather than inherited.

Describing a compiler is worth doing once. The modules under
`nix-haskell-compilers` are ready-made entries, imported like the patch
modules:

```nix
{ nix-haskell-compilers, ... }:
{
  imports = [
    (import "${nix-haskell-compilers}/ghc-wasm-meta" {
      flavour = "9.12";
      version = "9.12.4.20260731";
    })
  ];
}
```

#### Per-package customization

Tweaks for any package in the final package set, keyed by cabal package
name. Entries for packages that do not exist are silently ignored:

```nix
packages = {
  splitmix.patches = [ ./splitmix-js.patch ];
  reflex-dom-core.doCheck = false;
  my-app.flags.production = true;
  my-app.ghcOptions = [ "-Werror" ];
};
```

Fields: `flags`, `patches`, `ghcOptions`, `configureFlags`,
`setupBuildFlags`, `setupHaddockFlags`, `doCheck`, `doHaddock`, `doCoverage`,
`doHoogle`, `doHyperlinkSource`, `doQuickjump`, `dontStrip`,
`enableDeadCodeElimination`, `enableLibraryProfiling`, `enableProfiling`,
`profilingDetail`, `enableShared`, `enableStatic`,
`enableSeparateDataOutput`, `enableLibraryForGhci`, `hardeningDisable`,
`src`, the phase hooks `preUnpack`, `postUnpack`, `prePatch`,
`postPatch`, `preConfigure`, `postConfigure`, `preBuild`, `postBuild`,
`preCheck`, `postCheck`, `preHaddock`, `postHaddock`, `preInstall`,
`postInstall`, and the bundle optimizer settings `wasm-opt`,
`closure-compiler` and `components.exes.<exe>.{wasm-opt,closure-compiler}`.

One divergence to be aware of with the hooks: haskell.nix runs them for
each component derivation of the package, nixpkgs once in the single
package derivation.

The same fields can be given for one cross platform only, keyed by
`pkgs.pkgsCross` platform name, and are merged over the project-wide ones:

```nix
platforms.wasi32.packages.reflex-dom.flags.use-warp = false;
```

This is how a platform conditional in a cabal file or project file is
expressed for the nixpkgs driver, which has no solver to follow one. The flags
in particular decide a package's dependencies and not merely how it is
configured, so they take effect where the package's expression is generated
rather than on a package already built. The haskell.nix driver follows such
conditionals itself, and applies an entry given here in the project whose
target is that platform.

#### Bundle optimizers

What a driver gives back from a cross build is the artifact as linked: a `.wasm`
binary, or a `.jsexe` directory. Three read-only options turn one of those into
what gets shipped:

| Option | Takes | Gives |
|--------|-------|-------|
| `wasm-optimize` | `{ platform, package, exe, wasm }` | the binary through wasm-opt, then stripped of its custom sections |
| `wasm-jsffi` | `{ ghc, wasm }` | the `ghc_wasm_jsffi.js` a GHC-built wasm module cannot be instantiated without |
| `js-optimize` | `{ platform, package, exe, jsexe }` | the directory with its `all.js` closure-compiled |

```nix
let exe = project.projectCross.wasi32.hsPkgs.frontend.components.exes.frontend;
    wasm = "${exe}/bin/frontend.wasm";
    named = { platform = "wasi32"; package = "frontend"; exe = "frontend"; };
in pkgs.runCommand "frontend.wasm-bundle" {} ''
  mkdir -p $out
  cp ${config.wasm-jsffi {
        ghc = config.haskell-nix.cross-compiler "wasi32";
        inherit wasm;
      }} $out/ghc_wasm_jsffi.js
  cp ${config.wasm-optimize (named // { inherit wasm; })} $out/frontend.wasm
''
```

Run `wasm-jsffi` on the binary as linked, since `wasm-optimize` strips the
sections it reads. Its compiler has to be the one that built the binary, which
is what each driver's `cross-compiler` names, by `pkgs.pkgsCross` platform name.

Naming an executable is what gets it a bundle without calling anything, and for
the haskell.nix driver it is also what installs its `.jsexe`: that driver
installs only the bundled `bin/<exe>` for a javascript target, while
closure-compiler needs the directory the linker leaves beside it. The nixpkgs builder copies that
directory out on its own.

```nix
platforms.wasi32.packages.frontend.components.exes.frontend = {};
platforms.ghcjs.packages.frontend.components.exes.frontend = {};
```

The result is then on the tree, read through a driver, which is the only thing
that knows what it built:

```nix
let onTarget = config."haskell-nix".platforms.wasi32.packages.frontend;
in {
  wasm = onTarget.components.exes.frontend.bundles.optimized;
  jsffi = onTarget.components.exes.frontend.bundles.jsffi;
  everyExe = onTarget.bundles;   # the same, keyed by executable name
}
```

`optimized` is the executable through that target's optimizer, `jsffi` the
`ghc_wasm_jsffi.js` a wasm binary needs and `null` off a wasm target. Read
anywhere but through a driver, as `config.platforms.…`, both are `null`, since
there is no project to ask what it built. Neither is read-only: a project with
something else to ship can define either.

What each driver builds an executable into is `cross-exe`, which is what the
bundles optimize, and is there for anything else that wants a cross build by
name.

The flags come from `wasm-opt` and `closure-compiler`, and five layers can
speak for them. The names a transform is given are only what it looks the
settings up under, and any of them can be left out:

```nix
# whatever the target, for everything
wasm-opt.level = "2";

# whatever the target, for one package and then one executable of it
packages.frontend.wasm-opt.extraFlags = [ "--converge" ];
packages.frontend.components.exes.frontend.wasm-opt.level = "z";

# for one target, and the same two layers under it
platforms.wasi32.wasm-opt.level = "z";
platforms.wasi32.packages.frontend.wasm-opt.extraFlags = [ "--low-memory-unused" ];
platforms.wasi32.packages.frontend.components.exes.frontend.wasm-opt.enable = false;
```

The layer that states a field most specifically decides it, `null` states
nothing, and only `wasm-opt` and `closure-compiler` themselves hold every
field. From most specific to least: an executable of a package on one target,
that package on that target, that target, then the same executable and package
layers whatever the target, then the tool's own settings. `enable = false`
copies the input through instead, so the caller installs the same path either
way.

#### Source repository packages

`source-repository-packages` accepts either a path or an attrset with `src`,
optional `subdir` and optional `condition`:

```nix
source-repository-packages = {
  reflex-dom = {
    src = ./deps/reflex-dom;
    subdir = [ "reflex-dom" "reflex-dom-core" ];
  };
  obelisk-backend = {
    src = deps.obelisk + "/lib/backend";
    condition = "!arch(javascript)";
  };
};
```

#### Hackage overlays

Make custom packages visible to dependency resolution:

```nix
hackage-overlays = [
  {
    name = "my-package";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub { ... };
  }
];
```

#### Shell

```nix
shell = {
  crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
  packages = ps: with ps; [ common frontend "backend" ];
  tools = { cabal = "latest"; };
  buildInputs = [ pkgs.postgresql ];
  shellHook = "echo hello";
  withHoogle = false;
};
```

`crossPlatforms` selects over `pkgs.pkgsCross` platform names. When GHCJS or
WASM targets are selected, Node.js is automatically added to `buildInputs`.


### The haskell.nix driver

```nix
(nix-haskell ./project.nix).haskell-nix.project
```

The project is haskell.nix's: `hsPkgs.<pkg>.components.exes.<exe>`,
`projectCross.<platform>`, `shell`, etc.

Driver configuration:

| Option | Description |
|--------|-------------|
| `haskell-nix.options.*` | Any haskell.nix project option (`index-state`, `cabalProjectFreeze`, `extra-hackages`, `pkg-def-extras`, `shell.exactDeps`, `shell.withHaddock`, ...) |
| `haskell-nix.overrides` | haskell.nix `modules` to add to the project (lists concatenate when composed) |
| `haskell-nix.extraSrcFiles` | Extra files for the strictly tracked component builds |
| `haskell-nix.compiler-version` | The version of the compiler this driver builds with |
| `haskell-nix.cross-compiler` | `platform` to the compiler this driver builds that target with |
| `haskell-nix.cross-exe` | `{ platform, package, exe }` to what this driver builds that executable into |

```nix
haskell-nix.overrides = [
  ({ pkgs, lib, ... }: {
    packages.obelisk-command.components.library.build-tools = with pkgs; [ ghcid ];
    packages.reflex-dom-core.components.tests.gc.buildable = lib.mkForce false;
  })
];
```


### The nixpkgs driver

```nix
(nix-haskell ./project.nix).nixpkgs.project
```

The project:

```nix
{
  packages          # The project's own packages (packages.<name>)
  haskellPackages   # The full extended package set
  shell             # shellFor development shell
  projectCross      # Per pkgsCross platform (best effort)
  ghcWithPackages
}
```

haskell.nix's `hsPkgs.<name>.components.exes.<exe>` corresponds to
`packages.<name>` here, with the executable at `$out/bin/<exe>`.

Driver configuration:

| Option | Description |
|--------|-------------|
| `nixpkgs.compiler.name` | Per-driver override of the compiler, when the project's has no nixpkgs equivalent |
| `nixpkgs.compiler-version` | The version of the compiler this driver builds with |
| `nixpkgs.cross-compiler` | `platform` to the compiler this driver builds that target with |
| `nixpkgs.cross-exe` | `{ platform, package, exe }` to what this driver builds that executable into |
| `nixpkgs.pkgsCross` | Cross package sets for `projectCross`, replacing the ones from `pkgs.pkgsCross` |
| `nixpkgs.options.exact-configuration` | Tell Cabal every dependency and flag, so it resolves nothing and reads no version bound (follows `use-plan`) |
| `nixpkgs.options.overrides` | Overlays over the package set, applied last |
| `nixpkgs.options.packages` | Explicit local package map (bypasses discovery) |
| `nixpkgs.options.use-plan` | Take the project structure from the cabal plan of the haskell.nix driver |
| `nixpkgs.options.extra-package-defaults` | Jailbreak/check/haddock defaults for fetched packages |
| `nixpkgs.options.cross-package-defaults` | Jailbreak/haddock/profiling defaults for a cross set the driver builds itself |
| `nixpkgs.options.tool-packages` | Overrides for `shell.tools` resolution, `cabal` among them by default |
| `nixpkgs.options.shellFor-args` | Extra `shellFor` arguments |

Local packages are the package at the root of `src` by default.
`source-repository-package` stanzas in the project text (the project file
or `cabalProject`, plus `cabalProjectLocal` and `extraCabalProject`) are
parsed with haskell.nix's parser and honored: sources resolve through
`inputMap`, then `fetchgit` with hashes from `--sha256` comments or
`sha256map`. For multi-package projects either list the packages
explicitly:

```nix
nixpkgs.options.packages = {
  common.subdir = "common";
  frontend.subdir = "frontend";
};
```

or set `nixpkgs.options.use-plan = true` to reuse cabal's own reading of
`cabal.project` (exact globs, `optional-packages`, conditionals) at the cost
of evaluating the haskell.nix toolchain.

This driver has no solver, so a version bound written before the compiler in
hand is enforced rather than reasoned about, and `allow-newer` in a
`cabal.project` means nothing to it. `jailbreak` lifts the bounds a cabal file
states outright, and cannot reach one inside a conditional stanza.
`nixpkgs.options.exact-configuration` removes the question: Cabal is told every
direct dependency, by the id its package database records, and every flag the
package declares, so it resolves nothing and reads no bound. That is how the
haskell.nix driver configures every package, which is why `allow-newer` takes
effect there.

```nix
nixpkgs.options.exact-configuration =
  lib.versionAtLeast config.nixpkgs.compiler-version "9.14";
```

Caveats, by construction of nixpkgs' Haskell infrastructure:

- No version solving: dependency versions are those of the nixpkgs pin.
  `index-state` and `cabalProjectFreeze` do not exist here, and only the
  `source-repository-package` stanzas of the project text are interpreted;
  arch-conditional `package` flag stanzas are not. Flags that differ per
  driver go into the mirrored `nixpkgs.packages.<name>.flags`.
- Test suites run inside the package build; disable per package with
  `packages.<name>.doCheck = false`.
- `ghcOptions` applies to the project's own packages only, so the binary
  cache stays valid for the dependency closure.
- `shell.tools` versions are not solvable; tools resolve by name from `pkgs`
  and the package set.
- Cross-compilation mirrors `pkgs.pkgsCross`, which supports far fewer
  targets than haskell.nix. A `compiler.platforms` entry carrying a toolchain
  gets a package set built with that toolchain instead, which is what a target
  nixpkgs cannot assemble a working one for needs. A toolchain on the compiler
  above the table is not honored here, since only a cross set can be given one.


### Checks

Every driver declares a `translation` table: one entry per common option,
recording how it is honored. `nix flake check` verifies:

- `translation-totality`: the table keys of every driver equal the set of
  user-settable common options, in both directions. Adding a common option
  without teaching every driver about it fails evaluation.
- `every-option-<driver>`: a fixture setting every common option
  instantiates through the driver's whole translation.
- `hello-<driver>`: a hello example actually builds with each driver.

The haskell.nix checks want the IOG binary cache (configured in the flake's
`nixConfig`; pass `--accept-flake-config` if it is not in your nix.conf).

`release.nix` gathers those checks together with the reflex-todomvc example
built for every driver, compiler and cross target it is meant to work for, each
of them twice: as the drivers build it, and as a person would inside the
project's shell with the cross target's own cabal. It is a tree, reached as
`legacyPackages.<system>.release` through the flake:

```bash
nix-build release.nix -A checks
nix-build release.nix -A reflex-todomvc.build.haskell-nix.ghc912.wasi32
nix-build release.nix -A all      # the lot, one symlink tree
```

The matrix stays out of `nix flake check`, which builds only the repo's own
checks and stays quick.


### Inputs

Dependencies live under `inputs`, one entry per pin in `pins/`. An entry
accepts whatever a flake input can be: a flake input, a store path, a checkout,
or a packed thunk.

```nix
{
  inputs.haskell-nix = ./dep/your-haskell-nix;
  inputs.nixpkgs = inputs.nixpkgs;   # a flake input
}
```

The pins in `pins/` supply `nixpkgs` and `haskell-nix`. Entries of your
own can be added freely, and are resolved the same way.

Flake inputs are picked up automatically, so `inputs.nixpkgs` follows the
consuming flake's `nixpkgs` without any wiring. Precedence runs
`pins/` < flake inputs < whatever you set explicitly.


### Migration from the single-driver layout

The result attrset and some option spellings changed when the nixpkgs driver
was introduced:

| Old | New |
|-----|-----|
| `(nix-haskell m).nixpkgs` (the package set) | `(nix-haskell m).pkgs` |
| `overrides` | `haskell-nix.overrides` |
| `extraSrcFiles` | `haskell-nix.extraSrcFiles` |
| `cabalProjectFreeze`, `index-state` | `haskell-nix.options.<same>` |
| `extra-hackages`, `extra-hackage-tarballs`, `pkg-def-extras` | `haskell-nix.options.<same>` |
| `shell.withHaddock`, `shell.exactDeps`, `shell.allToolDeps`, ... | `haskell-nix.options.shell.<same>` |
| `overrides = [ { ghcOptions = [...]; } ]` | `ghcOptions = [...]` |
| `overrides = [ { packages.<n>.patches = [...]; } ]` | `packages.<n>.patches = [...]` |
| `compiler-nix-name = "ghc912"` | `compiler.name = "ghc912"` |
| `compiler = <package>` | `compiler.package = <package>` |
| `compiler = { <platform> = ...; }` | `compiler.platforms.<platform> = { ... }` |


### Full example

```nix
{ config, nix-haskell-patches, ... }:

{
  imports = [
    (import "${nix-haskell-patches}/js/splitmix" { drivers = [ "haskell-nix" ]; })
  ];

  name = "reflex-todomvc";
  src = ./.;

  source-repository-packages = {
    reflex-dom = {
      src = ./deps/reflex-dom;
      subdir = [ "reflex-dom" "reflex-dom-core" ];
    };
  };

  nixpkgs = {
    # webkitgtk (via jsaddle-webkit2gtk) still links libsoup 2
    pkgs = import config.inputs.nixpkgs {
      inherit (config) system;
      config.permittedInsecurePackages = [ "libsoup-2.74.3" ];
    };
    options.overrides = [
      # test dependency of reflex-dom-core, lives in the reflex-dom
      # repository; never built since checks are off for fetched packages
      (self: super: { chrome-test-utils = null; })
    ];
  };

  haskell-nix.extraSrcFiles = {
    library.extraSrcFiles = [ "static/style.css" ];
    exes.reflex-todomvc.extraSrcFiles = [ "static/style.css" ];
  };

  haskell-nix.options.shell.withHaddock = false;

  shell = {
    crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
    packages = ps: with ps; [ reflex-todomvc ];
    withHoogle = false;
  };
}
```


### Modules documentation

```
nix run --no-write-lock-file github:reflex-frp/nix-haskell#manual-view
```

or [docs/modules.md](docs/modules.md)


> **P.S.** The name is nothing clever: just the generic `{tool}-{lang}`
> pattern (nix-haskell, nix-rust, ...). The resemblance to
> [haskell.nix](https://github.com/input-output-hk/haskell.nix), which
> serves as one of the drivers here, is a coincidence of convention, not
> imitation.

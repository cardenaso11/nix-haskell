## packages



Per-package customization, keyed by cabal package name\. Entries for
packages that do not exist in the final package set are silently
ignored, so platform-conditional packages can be customized
unconditionally\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```
{
  splitmix.patches = [ ./splitmix-js.patch ];
  reflex-dom-core.doCheck = false;
  my-app.flags.production = true;
}
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.enableDeadCodeElimination



Whether to eliminate unused code at link time\. ` null ` leaves the
default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.enableLibraryForGhci



Whether to build a pre-linked object of the library for loading
into GHCi\. ` null ` leaves the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.enableLibraryProfiling



Whether to build the package’s library with profiling support\.
` null ` leaves the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.enableProfiling



Whether to build the whole package with profiling support\.
` null ` leaves the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.enableSeparateDataOutput



Whether to install the package’s data files into a separate
output\. ` null ` leaves the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.enableShared



Whether to build a shared library\. ` null ` leaves the default in
place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.enableStatic



Whether to build a static library\. ` null ` leaves the default in
place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.configureFlags



Extra flags passed to ` Setup configure `\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.doCheck



Whether to run the package’s test suites\. ` null ` leaves the
default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.doCoverage



Whether to generate a coverage report for the package\. ` null `
leaves the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.doHaddock



Whether to build the package’s documentation\. ` null ` leaves the
default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.doHoogle



Whether to generate a hoogle index for the package’s
documentation\. ` null ` leaves the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.doHyperlinkSource



Whether to generate hyperlinked source code alongside the
package’s documentation\. ` null ` leaves the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.doQuickjump



Whether to generate the quickjump index of the package’s
documentation\. ` null ` leaves the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.dontStrip



Whether to skip stripping the produced binaries\. ` null ` leaves
the default in place\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.flags



Cabal flag assignments for the package (` true ` enables,
` false ` disables)\.



*Type:*
attribute set of boolean



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.ghcOptions



GHC flags for this package only\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.hardeningDisable



Hardening flags to disable when building the package\. ` null `
leaves the default in place\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```



*Example:*

```nix
[
  "format"
]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.patches



Patches applied to the package source\.



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.postBuild



Shell code run after the
build phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.postCheck



Shell code run after the
check phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.postConfigure



Shell code run after the
configure phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.postHaddock



Shell code run after the
haddock phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.postInstall



Shell code run after the
install phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.postPatch



Shell code run after the
patch phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.postUnpack



Shell code run after the
unpack phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.preBuild



Shell code run before the
build phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.preCheck



Shell code run before the
check phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.preConfigure



Shell code run before the
configure phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.preHaddock



Shell code run before the
haddock phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.preInstall



Shell code run before the
install phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.prePatch



Shell code run before the
patch phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.preUnpack



Shell code run before the
unpack phase\. ` null ` leaves the default in
place\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.profilingDetail



The profiling detail level\. ` null ` leaves the default in place\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"toplevel-functions"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.setupBuildFlags



Extra flags passed to ` Setup build `\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.setupHaddockFlags



Extra flags passed to ` Setup haddock `\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.src



Replacement source for the package\.



*Type:*
null or absolute path or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## _module\.args

Additional arguments passed to each module in addition to ones
like ` lib `, ` config `,
and ` pkgs `, ` modulesPath `\.

This option is also available to all submodules\. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules\. The sole exception to
this is the argument ` name ` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute\.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:

 - ` lib `: The nixpkgs library\.

 - ` config `: The results of all options after merging the values from all modules together\.

 - ` options `: The options declared in all modules\.

 - ` specialArgs `: The ` specialArgs ` argument passed to ` evalModules `\.

 - All attributes of ` specialArgs `
   
   Whereas option values can generally depend on other option values
   thanks to laziness, this does not apply to ` imports `, which
   must be computed statically before anything else\.
   
   For this reason, callers of the module system can provide ` specialArgs `
   which are available during import resolution\.
   
   For NixOS, ` specialArgs ` includes
   ` modulesPath `, which allows you to import
   extra modules from the nixpkgs package tree without having to
   somehow make the module aware of the location of the
   ` nixpkgs ` or NixOS directories\.
   
   ```
   { modulesPath, ... }: {
     imports = [
       (modulesPath + "/profiles/minimal.nix")
     ];
   }
   ```

For NixOS, the default value for this option includes at least this argument:

 - ` pkgs `: The nixpkgs package set according to
   the ` nixpkgs.pkgs ` option\.



*Type:*
lazy attribute set of raw value



*Default:*

```nix
{ }
```

*Declared by:*
 - [\<nixpkgs/lib/modules\.nix>](https://github.com/NixOS/nixpkgs/blob//lib/modules.nix)



## cabalProject



Content of the ` cabal.project ` file\. ` null ` uses the file carried by
the source\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## cabalProjectFileName



Name of the cabal project file\.



*Type:*
string



*Default:*

```nix
"cabal.project"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## cabalProjectLocal



Content of the ` cabal.project.local ` file\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## clean-src



Filter ` src ` through the ` .gitignore ` it carries before copying it into
the store, so build artifacts (` dist-newstyle `, ` result `, ` .git `) do not
become part of every derivation that names the project source, and a
rebuild does not rehash them\. Only applies when ` src ` is a path; a
derivation is used as-is\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## clean-src-patterns



Extra gitignore-syntax patterns applied on top of the tree’s own
` .gitignore ` when ` clean-src ` is enabled\. Useful for artifacts that only
a nested ` .gitignore ` lists, since those patterns are not read\.



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```



*Example:*

```nix
''
  dist-wasm
  dist-js
''
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler



The GHC to build with: either the name of a compiler in the driver’s
package sets (` haskell-nix.compiler.<name> ` for the haskell\.nix
driver, ` pkgs.haskell.packages.<name> ` for the nixpkgs driver), or a
compiler package used directly, such as a bindist or a cross
compiler\. A package must carry a ` version ` attribute (or an explicit
` compiler-nix-name ` attribute), from which the drivers derive the
package-set name (“9\.12\.2” -> “ghc9122”)\.

Either form can also be given per platform, as an attrset keyed by
the native system and ` pkgsCross ` names (the keys of
` shell.crossPlatforms ` and ` projectCross `)\. Each platform resolves
its own entry; a platform without one fails when accessed\.



*Type:*
string or package or attribute set of (string or package)



*Default:*

```nix
"ghc914"
```



*Example:*

```nix
"ghc912"
# or a package:
inputs.ghc-wasm-meta.packages.${system}.all_9_12
# or a package with an explicit package-set name:
inputs.ghc-wasm-meta.packages.${system}.all_9_12 // {
  compiler-nix-name = "ghc9122";
}
# or per platform:
{
  x86_64-linux = "ghc912";
  wasi32 = inputs.ghc-wasm-meta.packages.x86_64-linux.all_9_12;
}

```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## extraCabalProject



Lines to append to ` cabal.project `\.



*Type:*
list of strings concatenated with “\\n”



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## ghcOptions



GHC flags applied project-wide\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "-O2"
  "-fexpose-all-unfoldings"
]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## hackage-overlays



Packages to make visible to dependency resolution without being
published to Hackage\. A good example of this is
obelisk-generated-static\.



*Type:*
list of (attribute set)



*Default:*

```nix
[ ]
```



*Example:*

```
[
  {
    name = "android-activity";
    version = "0.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "obsidiansystems";
      repo = "android-activity";
      rev = "2bc40f6f907b27c66428284ee435b86cad38cff8";
      sha256 = "sha256-AIpbe0JZX68lsQB9mpvR7xAIct/vwQAARVHAK0iChV4=";
    };
  }
]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## haskell-nix\.extraSrcFiles



ExtraSrcFiles to include in the project builds\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.haskell-nix



This option has no description\.



*Type:*
raw value



*Default:*

```
config."haskell-nix".nixpkgs.haskell-nix
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.input



This option has no description\.



*Type:*
raw value



*Default:*

```
import config.inputs."haskell-nix" { inherit system; }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.lib



This option has no description\.



*Type:*
raw value



*Default:*

```
config."haskell-nix".haskell-nix.haskellLib
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.nixpkgs



This option has no description\.



*Type:*
raw value



*Default:*

```
import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs)
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.nixpkgsArgs



This option has no description\.



*Type:*
raw value



*Default:*

```
config."haskell-nix".input.nixpkgsArgs
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.nixpkgsSource



This option has no description\.



*Type:*
raw value



*Default:*

```
config."haskell-nix".input.sources.nixpkgs-unstable
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options



This option has no description\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.builderVersion



Selects which component builder is used for per-component derivations\.

 - ` 1 ` (default) — the Setup\.hs-based builder (comp-builder\.nix)\.
 - ` 2 ` — the cabal v2-build-based slicing builder
   (comp-v2-builder\.nix)\.
   This is project-wide\.  Set it on the project module to switch
   builders; there is no per-component opt-in\.



*Type:*
signed integer



*Default:*

```nix
1
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.cabalProject



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.cabalProjectFileName



This option has no description\.



*Type:*
string



*Default:*

```nix
"cabal.project"
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.cabalProjectFreeze



This option has no description\.



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.cabalProjectLocal



This option has no description\.



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.checkMaterialization



If true the nix files will be generated used to check plan-sha256 and material



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.compiler-nix-name



The name of the ghc compiler to use eg\. “ghc884”



*Type:*
string

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.compilerSelection



Use GHC from pkgs\.haskell instead of pkgs\.haskell-nix



*Type:*
unspecified value



*Default:*

```nix
<function>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.configureArgs



Extra arguments to pass to ` cabal v2-configure `\.
` --enable-tests --enable-benchmarks ` are included by default\.
If the tests and benchmarks are not needed and they
cause the wrong plan to be chosen, then we can use
` configureArgs = "--disable-tests --disable-benchmarks"; `



*Type:*
null or strings concatenated with " "



*Default:*

```nix
""
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.crossPlatforms



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
<function>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.evalPackages



Packages used to run ` cabal ` and ` nix-tools `\.
This will default to ` pkgs.pkgsBuildBuild ` if it
matches the ` evalSystem ` (or if ` evalSystem ` was
not specified)\.
If a different ` evalSystem ` was requested, ` evalPackages ` will
default to be:
import pkgs\.path {
system = config\.evalSystem;
overlays = pkgs\.overlays;
};



*Type:*
attribute set



*Default:*

```
if pkgs.pkgsBuildBuild.stdenv.system == config.evalSystem
then pkgs.pkgsBuildBuild
else
  import pkgs.path {
    system = config.evalSystem;
    overlays = pkgs.overlays;
  };
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.evalSrc



Allows a different version of the src to be used at eval time\.
This is useful when building the source may require a build machine\.
To avoid an eval time dependency on a build machine set ` evalSrc `
to either:

 - A version of the source built using ` evalPackages `
 - A version of the source that does not require building



*Type:*
absolute path or package



*Default:*

```nix
<nix-haskell>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.evalSystem



Specifies the system on which ` cabal ` and ` nix-tools ` should run\.
If not specified the ` pkgsBuildBuild ` system will be used\.
If there are no builders for the ` pkgsBuildBuild ` system
specifying a system for which there are builders will
allow the evaluation of the haskell project to work\.



*Type:*
string



*Default:*

```nix
"x86_64-linux"
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.extra-hackage-tarballs



This option has no description\.



*Type:*
null or (attribute set)



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.extra-hackages



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake



Default arguments to use for the ` p.flake `\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.packages



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
<function>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.coverageProjectModule



Project module for use when generating coverage reports\.
The project packages will have ` packages.X.doCoverage `
turned on by default\.



*Type:*
unspecified value



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.crossPlatforms



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
<function>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.doCoverage



Specifies if the flake ` ciJobs ` and ` hydraJobs ` should include code
coverage reports\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.variants



This allows flakes to easily include variations of the
project by with different project arguments\.
Anything you can pass to ` project.addModule ` can be used\.
For instance to include variants using ghc 9\.2\.6:

```
  flake.variants.ghc928.compiler-nix-name = pkgs.lib.mkForce "ghc928";
```

Then use it with:

```
  nix build .#ghc928:hello:exe:hello
```



*Type:*
attribute set of unspecified value



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.ghc



Deprecated in favour of ` compiler-nix-name `



*Type:*
null or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.ghcOverride



Used when we need to set ghc explicitly during bootstrapping



*Type:*
null or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.hsPkgs



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.ignorePackageYaml



If set, prevents nix-tools from attempting to load package\.yaml even if it is present\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.index-sha256



The hash of the truncated hackage index-state



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.index-state



Hackage index-state, eg\. “2019-10-10T00:00:00Z”



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.inputMap



Specifies the contents of urls in the cabal\.project file\.
The ` .rev ` attribute is checked against the ` tag ` for ` source-repository-packages `\.

For ` revision ` blocks the ` inputMap.<url> ` will be used and
they ` .tar.gz ` for the ` packages ` used will also be looked up
in the ` inputMap `\.



*Type:*
null or (attribute set)



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.materialized



Location of a materialized copy of the nix files



*Type:*
null or absolute path or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.modules



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.name



Optional name for better error messages



*Type:*
null or string



*Default:*

```nix
"haskell-project"
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.nix-tools



nix-tools to use when converting the ` plan.json ` to nix



*Type:*
null or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.pkg-def-extras



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.plan-sha256



The hash of the plan-to-nix output (makes the plan-to-nix step a fixed output derivation)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.prebuilt-depends



pre-built (perhaps proprietary) Haskell packages to make available as dependencies

See Note \[prebuilt dependencies] for more details



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.projectFileName



This option has no description\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.sha256map



An alternative to adding ` --sha256 ` comments into the
cabal\.project file:
sha256map =
{ “https://github\.com/jgm/pandoc-citeproc”\.“0\.17”
= “0dxx8cp2xndpw3jwiawch2dkrkp15mil7pyx7dvd810pwc22pm2q”; };



*Type:*
null or (attribute set of (string or attribute set of string))



*Default:*

```nix
{
  "https://github.com/pepeiborra/ekg-json" = {
    "7a0af7a8fd38045fd15fb13445bdcc7085325460" = "sha256-fVwKxGgM0S4Kv/4egVAAiAjV7QB5PBqMVMCfsv7otIQ=";
  };
}
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell



Arguments to use for the default shell ` p.shell ` (these are passed to p\.shellFor)\.
For instance to include ` cabal ` and ` ghcjs ` support use
shell = { tools\.cabal = {}; crossPlatforms = p: \[ p\.ghcjs ]; }



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.enableDWARF



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.packageSetupDeps



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.packages



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
<function>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.additional



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
<function>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.allToolDeps



Indicates if the shell should include all the tool dependencies
of the haskell packages in the project\.  Defaulted to ` false ` in
stack projects (to avoid trying to build the tools used by
every ` stackage ` package)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.buildInputs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.components



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
<function>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.crossPlatforms



This option has no description\.



*Type:*
unspecified value



*Default:*

```nix
<function>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.exactDeps



This option has no description\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.exposePackagesVia



How the v2 shell’s pre-built library deps are made visible to
tools the user runs\.  One of:

 - “cabal-store” (default) — the composed store is copied
   into ` ~/.cabal/store/<ghc>-inplace/ ` via a shellHook
   (or the explicit ` haskell-nix-cabal-store-sync ` command)\.
   ` cabal v2-build ` then reuses the units directly\.  The
   shell’s ` ghc ` is left plain, so ` runghc `/` ghci ` will not
   see the deps\.
 - “ghc-pkg” — the shell’s ` ghc ` is wrapped with
   GHC_ENVIRONMENT pointing at the composed store’s
   package\.db, so ` ghc `/` ghci `/` runghc `/` ghc-pkg ` see every
   dep directly\.  No files are written outside the shell\.
   Only affects ` shellFor ` under ` builderVersion = 2 `\.



*Type:*
one of “cabal-store”, “ghc-pkg”



*Default:*

```nix
"cabal-store"
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.inputsFrom



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.name



This option has no description\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.nativeBuildInputs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.passthru



This option has no description\.



*Type:*
attribute set of unspecified value



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.shellHook



This option has no description\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.tools



This option has no description\.



*Type:*
attribute set of unspecified value



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.withHaddock



This option has no description\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.withHoogle



This option has no description\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.source-repo-override



This option has no description\.



*Type:*
attribute set of function that evaluates to a(n) (attribute set)



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.src



This option has no description\.



*Type:*
absolute path or package

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.supportHpack



This option has no description\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.useLocalGhcLib



Expose the GHC compiler tree (configured-src + generated, the
` compiler/ ` subdir thereof) to the planner as a regular
reinstallable package source\.  Use this when the project
depends on / constrains the ` ghc ` package — e\.g\.
` ghc-lib-reinstallable `\.

The project-level wiring differs by builder:

 - Cabal projects (see ` modules/cabal-project.nix `) inject a
   ` source-repository-package ` block into ` cabalProjectLocal `
   so cabal hashes the wrapped repo’s content into
   ` pkg-src-sha256 `\.  Both plan-to-nix and the v2 slice see
   the same repo, so UnitIds align\.
 - Stack projects (see ` modules/stack-project.nix `) re-add
   the post-plan ` packages.ghc.src ` override that
   ` modules/configuration-nix.nix ` used to apply
   unconditionally — stack only supports the v1 builder for
   now, so the post-plan override is harmless (v1 doesn’t
   enforce UnitId alignment)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.overrides



haskell\.nix ` modules ` to add to the project\. The escape hatch for
anything the common options do not cover\. Lists are concatenated
when composed (not replaced)\.



*Type:*
list of unspecified value



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.project



This option has no description\.



*Type:*
raw value



*Default:*

```
config.haskell-nix.haskell-nix.project config.haskell-nix.options
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## inputMap



Specifies the contents of urls in the cabal\.project file, so sources
named there resolve without fetching\.
The ` .rev ` attribute is checked against the ` tag ` for ` source-repository-packages `\.



*Type:*
attribute set



*Default:*

```nix
{ }
```



*Example:*

```
  inputMap = {
    "{url}/{rev/ref}" = dep_src;
    "https://github.com/obsidiansystems/obelisk-oauth.git/a528c0542e9c30851e7c4542468a053fa5e482ef" = thunkSource ./dep/{thunk};
  };
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## inputs



Sources of dependencies, keyed the way flake inputs are\. An entry
accepts whatever a flake input can be: a flake input, a store path, a
checkout, or a packed thunk\. Entries beyond the ones in ` pins/ ` may be
added freely\.



*Type:*
attribute set of raw value



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/inputs\.nix](file://<nix-haskell>/modules/inputs.nix)



## isGhcjs



Whether the project targets GHCJS (either natively or via cross-compilation)\.
Used to conditionally include JavaScript runtime dependencies\.



*Type:*
boolean



*Default:*

```nix
''
  let # Create probe set mapping each platform name to itself
      # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
      probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
      # Get list of selected platform names as strings
      selected = config.shell.crossPlatforms probeSet;
  in # Native GHCJS: the shell itself is for a GHCJS platform
        pkgs.stdenv.hostPlatform.isGhcjs
     # Cross-compilation: GHCJS is among the selected cross targets
     || builtins.elem "ghcjs" selected;
''
```

*Declared by:*
 - [<nix-haskell>/modules/cross/ghcjs](file://<nix-haskell>/modules/cross/ghcjs)



## isWasm



Whether the project targets WASM (either natively or via cross-compilation)\.
Used to conditionally include WebAssembly runtime dependencies\.



*Type:*
boolean



*Default:*

```nix
''
  let # Create probe set mapping each platform name to itself
      # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
      probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
      # Get list of selected platform names as strings
      selected = config.shell.crossPlatforms probeSet;
  in # Native WASM: the shell itself is for a WASM platform
        pkgs.stdenv.hostPlatform.isWasm
     # Cross-compilation: a WASM target is among the selected cross targets
     || builtins.any (name: hasInfix "wasm" name || hasPrefix "wasi" name) selected;
''
```

*Declared by:*
 - [<nix-haskell>/modules/cross/wasm](file://<nix-haskell>/modules/cross/wasm)



## name



Optional name for better error messages\.



*Type:*
null or string



*Default:*

```nix
"7535csspmc38xp80wkn2hdg5r5k883qs-source"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## nixpkgs\.haskellPackages



The base Haskell package set, before the project’s packages and
overrides are layered on top\.



*Type:*
raw value



*Default:*

```
config.nixpkgs.pkgs.haskell.packages.${config.nixpkgs.compiler}
```

A package compiler overrides that set’s ` ghc ` instead, falling
back to ` pkgs.haskellPackages ` when no set matches its derived
name\.

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options



nixpkgs-specific project options\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.packages



Explicit map of the project’s local packages, keyed by cabal
package name\. Overrides discovery entirely\.



*Type:*
null or (attribute set of (submodule))



*Default:*

```nix
null
```



*Example:*

```
{
  common.subdir = "common";
  frontend.subdir = "frontend";
}
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.packages\.\<name>\.subdir



Directory of the package within the project source\.



*Type:*
string



*Default:*

```nix
"."
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.extra-package-defaults



Defaults applied to packages rooted outside the project
source (source-repository-packages, hackage-overlays)\.
Without a solver their version bounds routinely need
loosening\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.extra-package-defaults\.check



Run their test suites\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.extra-package-defaults\.haddock



Build their documentation\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.extra-package-defaults\.jailbreak



Lift version bounds (` haskell.lib.doJailbreak `)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.overrides



Overlays over the Haskell package set (` self: super: { ... } `),
applied after everything the driver generates\. The escape
hatch for anything the common options do not cover\.



*Type:*
list of raw value



*Default:*

```nix
[ ]
```



*Example:*

```
[ (self: super: { my-dep = pkgs.haskell.lib.dontCheck super.my-dep; }) ]
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.shellFor-args



Extra arguments passed to ` shellFor ` verbatim
(` extraDependencies `, ` doBenchmark `, …)\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.tool-packages



Overrides for ` shell.tools ` resolution, keyed by tool name\.
By default a tool is looked up as ` pkgs.<name> ` and then in
the Haskell package set; version requests are ignored, since
nixpkgs carries a single version\.



*Type:*
attribute set of package



*Default:*

```nix
{ }
```



*Example:*

```
{ haskell-language-server = pkgs.haskell-language-server; }
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.use-plan



Take the project’s structure (local packages, their
directories, source-repository-packages) from the cabal plan
of the haskell\.nix driver instead of the root of the source\.
This is cabal’s own reading of cabal\.project, so globs,
optional-packages and conditionals are all exact, at the cost
of evaluating the haskell\.nix toolchain (import from
derivation)\. The packages are still built from nixpkgs\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.pkgs



The nixpkgs package set the driver builds with\.



*Type:*
raw value



*Default:*

```
import config.inputs.nixpkgs { inherit (config) system; }
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.project



The built project: ` packages ` (the project’s own packages),
` haskellPackages ` (the full extended set), ` shell `, ` projectCross `
(per ` pkgsCross ` platform) and ` ghcWithPackages `\.



*Type:*
raw value



*Default:*

```
import <nix-haskell>/libs/nixpkgs/driver.nix {
  pkgs = config.nixpkgs.pkgs;
  haskellPackages = config.nixpkgs.haskellPackages;
  inherit lib config;
}
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## optimizations\.O2



Enable -O2 optimization level\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.all

Enable all optimization flags\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.cross-module-specialise



Enable -fcross-module-specialise\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.expose-all-unfoldings



Enable -fexpose-all-unfoldings for cross-module optimization\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.late-specialise



Enable -flate-specialise\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.specialise



Enable -fspecialise\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.specialise-aggressively



Enable -fspecialise-aggressively\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## sha256map



An alternative to adding ` --sha256 ` comments into the cabal\.project file\.



*Type:*
null or (attribute set of (string or attribute set of string))



*Default:*

```nix
null
```



*Example:*

```
  sha256map = {
    "url"."rev/ref" = "hash"
    "https://github.com/jgm/pandoc-citeproc"."0.17" = "0dxx8cp2xndpw3jwiawch2dkrkp15mil7pyx7dvd810pwc22pm2q";
    "https://github.com/obsidiansystems/obelisk-oauth.git"."a528c0542e9c30851e7c4542468a053fa5e482ef" = lib.fakeHash;
  };
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell



Development shell configuration\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.packages



Package selection function\. It takes a set of Haskell packages and returns a subset of these packages with all of their dependencies included in ` ghc-pkg list `\.
It can take either a ` package ` or name (` string `) of a package which availability can depend on the platform\.



*Type:*
null or unspecified value



*Default:*
` null ` (all local packages that are not
` source-repository-packages ` are selected)



*Example:*

````
ps: with ps; [
  common
  frontend
  "backend" # Provided by name so that it is only included when it's among `ps`
]
````

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.buildInputs



Extra packages available in the shell\.



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.crossPlatforms



Selector for cross-compilation targets, over an attribute set
keyed by ` pkgs.pkgsCross ` platform names\.



*Type:*
unspecified value



*Default:*

```
ps: []
```



*Example:*

```
ps: with ps; [ ghcjs wasi32 ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.nativeBuildInputs



Extra native packages available in the shell\.



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.shellHook



Shell hook to run when entering the shell\.



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.tools



Haskell tools available in the shell, keyed by executable name\.
The value is a version request such as ` "latest" `, a version
string, or a tool argument set\.



*Type:*
attribute set of raw value



*Default:*

```nix
{ }
```



*Example:*

```
{ cabal = "latest"; haskell-language-server = "latest"; }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.withHoogle



Provide a hoogle database over the shell’s package set\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## source-repository-packages



Local packages to add to the project\. A source is anything ` inputs `
accepts, so a packed thunk directory can be given as-is and is
resolved to the source it pins\.

` subdir ` selects packages within the source, so a multi-package
repository needs one entry rather than one per package\.



*Type:*
attribute set of (absolute path or (attribute set))



*Default:*

```nix
{ }
```



*Example:*

```
{
  obelisk-frontend = deps.obelisk + "/lib/frontend";
  obelisk-backend = {
    src = deps.obelisk + "/lib/backend";
    condition = "!arch(javascript)";
  };

  reflex-dom = deps.reflex-dom + "/reflex-dom";
  reflex-dom-core = deps.reflex-dom + "/reflex-dom-core";
  reflex = deps.reflex;
}
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## src



This option has no description\.



*Type:*
absolute path or package



*Example:*

```nix
"./."
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## src-cleaned



` src ` with build artifacts filtered out, or ` src ` itself when
` clean-src ` is disabled\. This is what the project is actually built
from\.



*Type:*
absolute path or package *(read only)*



*Default:*

```
  import ../libs/clean-source.nix { inherit pkgs; } {
    src = config.src;
    name = config.name;
    patterns = config.clean-src-patterns;
  }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## system



This option has no description\.



*Type:*
string



*Default:*

```nix
''
  builtins.currentSystem
''
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



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



## packages\.\<name>\.closure\.enable



Whether ` js-optimize ` runs closure-compiler at all\. When false it
copies the jsexe through unchanged\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.closure\.externs



Files passed as ` --externs `, declaring what the program reaches by a
name the compiler must not rename\. The jsexe’s own ` all.externs.js ` is
always passed ahead of these, since ADVANCED renames everything it is
not told the runtime knows by name\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of absolute path)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.closure\.extraFlags



Flags appended after the level and the externs, so one of these decides
what they would have\. One flag per element, its value in the same
string, since the elements are joined into one command line\.

The default accepts whatever syntax the linker emitted, keeps the
compiler quiet, wraps the program in a function expression it may
assume nothing escapes from, asks for strict mode, and stops it
complaining about the names the runtime defines elsewhere\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.closure\.level



The ` --compilation_level ` closure-compiler runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “BUNDLE”, “WHITESPACE_ONLY”, “SIMPLE”, “TRANSPILE_ONLY”, “ADVANCED”



*Default:*

```nix
null
```



*Example:*

```nix
"SIMPLE"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components



Per-component customization, under the kind cabal knows the
component by\. Only executables carry anything so far\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components\.exes



Bundle optimizer settings for one executable of the package,
keyed by the name cabal gives it\. They sit under an executable
rather than the package because a bundle is what an executable
links to, and a package can carry several\.

Naming an executable here is also what tells the haskell\.nix
driver to install that executable’s ` .jsexe ` directory, which
it otherwise leaves in the build tree\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components\.exes\.\<name>\.closure\.enable



Whether ` js-optimize ` runs closure-compiler at all\. When false it
copies the jsexe through unchanged\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components\.exes\.\<name>\.closure\.externs



Files passed as ` --externs `, declaring what the program reaches by a
name the compiler must not rename\. The jsexe’s own ` all.externs.js ` is
always passed ahead of these, since ADVANCED renames everything it is
not told the runtime knows by name\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of absolute path)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components\.exes\.\<name>\.closure\.extraFlags



Flags appended after the level and the externs, so one of these decides
what they would have\. One flag per element, its value in the same
string, since the elements are joined into one command line\.

The default accepts whatever syntax the linker emitted, keeps the
compiler quiet, wraps the program in a function expression it may
assume nothing escapes from, asks for strict mode, and stops it
complaining about the names the runtime defines elsewhere\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components\.exes\.\<name>\.closure\.level



The ` --compilation_level ` closure-compiler runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “BUNDLE”, “WHITESPACE_ONLY”, “SIMPLE”, “TRANSPILE_ONLY”, “ADVANCED”



*Default:*

```nix
null
```



*Example:*

```nix
"SIMPLE"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components\.exes\.\<name>\.wasm-opt\.enable



Whether ` wasm-optimize ` runs wasm-opt and the strip that follows it at
all\. When false it copies its input through, so what a caller installs
sits in the same place either way\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components\.exes\.\<name>\.wasm-opt\.extraFlags



Flags appended after ` -all -O<level> `, so one of these decides what the
level would have\. One flag per element, its value in the same string,
since the elements are joined into one command line\.

The default asks for the optimize level of ` -O2 ` at the shrink level of
` -O1 `, drops the memory a module never reads, discards debug
information, and repeats the passes until they stop finding anything\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.components\.exes\.\<name>\.wasm-opt\.level



The ` -O ` level wasm-opt runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “0”, “1”, “2”, “3”, “4”, “s”, “z”



*Default:*

```nix
null
```



*Example:*

```nix
"z"
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



## packages\.\<name>\.wasm-opt\.enable



Whether ` wasm-optimize ` runs wasm-opt and the strip that follows it at
all\. When false it copies its input through, so what a caller installs
sits in the same place either way\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.wasm-opt\.extraFlags



Flags appended after ` -all -O<level> `, so one of these decides what the
level would have\. One flag per element, its value in the same string,
since the elements are joined into one command line\.

The default asks for the optimize level of ` -O2 ` at the shrink level of
` -O1 `, drops the memory a module never reads, discards debug
information, and repeats the passes until they stop finding anything\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## packages\.\<name>\.wasm-opt\.level



The ` -O ` level wasm-opt runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “0”, “1”, “2”, “3”, “4”, “s”, “z”



*Default:*

```nix
null
```



*Example:*

```nix
"z"
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



## clean-src-ignore-files



The ignore files read when ` clean-src ` is enabled, relative to the root
of the source tree\. Every pattern is interpreted with the root as its
base, whichever file it came from, so an anchored pattern in a nested
file (` dist/* `) matches against the root rather than against the
directory the file sits in; where that matters, give the pattern
through ` clean-src-patterns ` instead\.



*Type:*
list of string



*Default:*

```nix
[
  "/.gitignore"
]
```



*Example:*

```nix
[
  "/.gitignore"
  "/frontend/.gitignore"
]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## clean-src-patterns



Extra gitignore-syntax patterns, applied on top of the files
` clean-src-ignore-files ` names, when ` clean-src ` is enabled\. A bare
pattern (` dist-js `) matches at any depth, which is what an anchored one
read against the root cannot do\.



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



## closure\.enable



Whether ` js-optimize ` runs closure-compiler at all\. When false it
copies the jsexe through unchanged\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/cross/ghcjs](file://<nix-haskell>/modules/cross/ghcjs)



## closure\.externs



Files passed as ` --externs `, declaring what the program reaches by a
name the compiler must not rename\. The jsexe’s own ` all.externs.js ` is
always passed ahead of these, since ADVANCED renames everything it is
not told the runtime knows by name\.



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/cross/ghcjs](file://<nix-haskell>/modules/cross/ghcjs)



## closure\.extraFlags



Flags appended after the level and the externs, so one of these decides
what they would have\. One flag per element, its value in the same
string, since the elements are joined into one command line\.

The default accepts whatever syntax the linker emitted, keeps the
compiler quiet, wraps the program in a function expression it may
assume nothing escapes from, asks for strict mode, and stops it
complaining about the names the runtime defines elsewhere\.



*Type:*
list of string



*Default:*

```nix
[
  "--language_in UNSTABLE"
  "--warning_level QUIET"
  "--isolation_mode IIFE"
  "--assume_function_wrapper"
  "--emit_use_strict"
  "--jscomp_off=undefinedVars"
]
```

*Declared by:*
 - [<nix-haskell>/modules/cross/ghcjs](file://<nix-haskell>/modules/cross/ghcjs)



## closure\.level



The ` --compilation_level ` closure-compiler runs at\.



*Type:*
one of “BUNDLE”, “WHITESPACE_ONLY”, “SIMPLE”, “TRANSPILE_ONLY”, “ADVANCED”



*Default:*

```nix
"ADVANCED"
```



*Example:*

```nix
"SIMPLE"
```

*Declared by:*
 - [<nix-haskell>/modules/cross/ghcjs](file://<nix-haskell>/modules/cross/ghcjs)



## compiler



The GHC to build with\. ` name ` selects one of the driver’s own
compilers; ` package ` supplies one from outside them, and the fields
around it are the attributes the drivers read off a compiler\.
` platforms ` gives cross targets their own compiler and toolchain; a
platform without an entry uses the fields above it\.

A compiler that has to be described this way is worth writing once:
the modules under ` nix-haskell-compilers ` are ready-made entries for
compilers distributed outside the drivers’ package sets\.



*Type:*
submodule



*Default:*

```nix
{ }
```



*Example:*

````nix
{
  name = "ghc912";

  # a bindist for the wasm target, with the toolchain it was built
  # with, as `nix-haskell-compilers/ghc-wasm-meta` supplies it
  platforms.wasi32 = {
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
}

````

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.enableShared



Whether the compiler can build shared libraries\. The haskell\.nix
driver reads it for every component’s ` shared: ` flag; the nixpkgs
driver builds a cross package set non-static, with shared and not
static libraries\. GHC’s wasm backend needs it, because its Template
Haskell interpreter loads shared objects\.



*Type:*
null or boolean



*Default:*
` null `: the ` enableShared ` of ` package `, else ` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.package



A compiler used directly instead of one from the driver’s package
sets: a bindist, an out-of-tree cross compiler, a locally built
GHC\. The fields around it are spliced onto it, since both drivers
read them off the compiler itself and a bindist generally carries
none of them\.



*Type:*
null or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.haskell-nix



Compiler details only the haskell\.nix driver reads\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.haskell-nix\.extraNonReinstallablePkgs



Packages taken from the compiler’s own database rather than
built, on top of the ones the driver already treats that way\.
A package the compiler was configured against, but which is
absent from the lists the driver copies out of it, belongs
here: a build that reaches for it finds nothing to depend on,
and everything downstream of it breaks\. A compiler whose
` text ` is built against simdutf needs ` system-cxx-std-lib `
this way\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "system-cxx-std-lib"
]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.haskell-nix\.libDir



The compiler’s library directory, relative to its store path,
where the driver looks for the package database and
` settings `\. A relocatable bindist keeps them directly under
` lib `, rather than under the ` lib/<prefix>ghc-<version>/lib `
of a version-named install\.



*Type:*
null or string



*Default:*
` null `: the ` libDir ` of ` package `, else the path haskell\.nix
derives from the version



*Example:*

```nix
"lib"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.name



The compiler’s name in the driver’s package sets
(` haskell-nix.compiler.<name> `, ` pkgs.haskell.packages.<name> `),
and the name the project’s packages are pinned under\. With
` package ` set it names the set whose compiler the package replaces,
and only needs to be given when the name derived from the version
is not one the driver knows\.



*Type:*
null or string



*Default:*
` null `: the driver’s own compiler, ` ghc914 ` for haskell\.nix and
` ghc912 ` for nixpkgs, where no stackage snapshot covers 9\.14 yet



*Example:*

```nix
"ghc912"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.nixpkgs



Compiler details only the nixpkgs driver reads\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.nixpkgs\.enableExternalInterpreter



Whether to run Template Haskell splices through nixpkgs’
external interpreter, which proxies them to the target over a
socket\. ` false ` for a compiler that runs splices itself, such
as GHC’s wasm backend, and necessary for a target that has no
sockets to proxy over\.



*Type:*
null or boolean



*Default:*
` null `: nixpkgs’ own choice, which is to use the external
interpreter whenever it is cross-compiling and an emulator
exists for the target

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.nixpkgs\.haskellCompilerName



The compiler’s cabal name\. The driver names the package
database directories of everything it builds after it, and
passes it to cabal2nix as ` --compiler `\.



*Type:*
null or string



*Default:*
` null `: the ` haskellCompilerName ` of ` package `, else
` ghc-<version> `



*Example:*

```nix
"ghc-9.12.4.20260731"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms



Per-platform compilers, keyed by ` pkgsCross ` platform name (the
keys of ` shell.crossPlatforms ` and ` projectCross `)\. An entry has
the same fields as the compiler above, and the fields it leaves
unset are resolved from its own ` package ` rather than inherited\.
A per-driver definition anywhere under ` compiler.platforms `
replaces the whole table for that driver, since a mirror seeds
submodule fields only one level deep\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.enableShared



Whether the compiler can build shared libraries\. The haskell\.nix
driver reads it for every component’s ` shared: ` flag; the nixpkgs
driver builds a cross package set non-static, with shared and not
static libraries\. GHC’s wasm backend needs it, because its Template
Haskell interpreter loads shared objects\.



*Type:*
null or boolean



*Default:*
` null `: the ` enableShared ` of ` package `, else ` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.package



A compiler used directly instead of one from the driver’s package
sets: a bindist, an out-of-tree cross compiler, a locally built
GHC\. The fields around it are spliced onto it, since both drivers
read them off the compiler itself and a bindist generally carries
none of them\.



*Type:*
null or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.haskell-nix



Compiler details only the haskell\.nix driver reads\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.haskell-nix\.extraNonReinstallablePkgs



Packages taken from the compiler’s own database rather than
built, on top of the ones the driver already treats that way\.
A package the compiler was configured against, but which is
absent from the lists the driver copies out of it, belongs
here: a build that reaches for it finds nothing to depend on,
and everything downstream of it breaks\. A compiler whose
` text ` is built against simdutf needs ` system-cxx-std-lib `
this way\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "system-cxx-std-lib"
]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.haskell-nix\.libDir



The compiler’s library directory, relative to its store path,
where the driver looks for the package database and
` settings `\. A relocatable bindist keeps them directly under
` lib `, rather than under the ` lib/<prefix>ghc-<version>/lib `
of a version-named install\.



*Type:*
null or string



*Default:*
` null `: the ` libDir ` of ` package `, else the path haskell\.nix
derives from the version



*Example:*

```nix
"lib"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.name



The compiler’s name in the driver’s package sets
(` haskell-nix.compiler.<name> `, ` pkgs.haskell.packages.<name> `),
and the name the project’s packages are pinned under\. With
` package ` set it names the set whose compiler the package replaces,
and only needs to be given when the name derived from the version
is not one the driver knows\.



*Type:*
null or string



*Default:*
` null `: the driver’s own compiler, ` ghc914 ` for haskell\.nix and
` ghc912 ` for nixpkgs, where no stackage snapshot covers 9\.14 yet



*Example:*

```nix
"ghc912"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.nixpkgs



Compiler details only the nixpkgs driver reads\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.nixpkgs\.enableExternalInterpreter



Whether to run Template Haskell splices through nixpkgs’
external interpreter, which proxies them to the target over a
socket\. ` false ` for a compiler that runs splices itself, such
as GHC’s wasm backend, and necessary for a target that has no
sockets to proxy over\.



*Type:*
null or boolean



*Default:*
` null `: nixpkgs’ own choice, which is to use the external
interpreter whenever it is cross-compiling and an emulator
exists for the target

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.nixpkgs\.haskellCompilerName



The compiler’s cabal name\. The driver names the package
database directories of everything it builds after it, and
passes it to cabal2nix as ` --compiler `\.



*Type:*
null or string



*Default:*
` null `: the ` haskellCompilerName ` of ` package `, else
` ghc-<version> `



*Example:*

```nix
"ghc-9.12.4.20260731"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.targetPrefix



The prefix the compiler’s executables carry\. Every tool either
driver invokes is named with it\.



*Type:*
null or string



*Default:*
` null `: the ` targetPrefix ` of ` package `, else the empty string



*Example:*

```nix
"wasm32-wasi-"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.toolchain



The C toolchain the compiler was configured with, when that is not
the one the surrounding package set supplies\. Everything built with
the compiler is pointed back at it, since ` Setup configure `’s
foreign-dependency checks otherwise look in the wrong sysroot: the
haskell\.nix driver passes it as every package’s configure flags,
the nixpkgs driver makes it the cross package set’s toolchain
outright\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.toolchain\.package



The toolchain itself\. The nixpkgs driver also makes it a
setup dependency of every package, so that a setup hook
exporting ` CC `, ` AR ` and friends is honored\.



*Type:*
null or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.toolchain\.ar



The archiver’s name in the toolchain’s ` bin `, passed to cabal
as ` --with-ar `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"llvm-ar"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.toolchain\.cc



The C compiler’s name in the toolchain’s ` bin `, passed to
cabal as ` --with-gcc `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"wasm32-wasi-clang"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.toolchain\.ld



The linker’s name in the toolchain’s ` bin `, passed to cabal
as ` --with-ld `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"wasm-ld"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.toolchain\.strip



The strip utility’s name in the toolchain’s ` bin `, passed to
cabal as ` --with-strip `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"llvm-strip"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.platforms\.\<name>\.version



The compiler’s version\. Both drivers read it off the compiler, for
paths and for ` impl(ghc >= ...) ` conditionals, and the stock
compiler of the same major\.minor\.patch is what the builds that
cannot use the package itself fall back to: the nixpkgs package set
the project is built against, and haskell\.nix’s shell tools\. Worth
setting for a nightly bindist, whose name carries only its series\.



*Type:*
null or string



*Default:*
` null `: the ` version ` of ` package `, else the version in its name



*Example:*

```nix
"9.12.4.20260731"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.targetPrefix



The prefix the compiler’s executables carry\. Every tool either
driver invokes is named with it\.



*Type:*
null or string



*Default:*
` null `: the ` targetPrefix ` of ` package `, else the empty string



*Example:*

```nix
"wasm32-wasi-"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.toolchain



The C toolchain the compiler was configured with, when that is not
the one the surrounding package set supplies\. Everything built with
the compiler is pointed back at it, since ` Setup configure `’s
foreign-dependency checks otherwise look in the wrong sysroot: the
haskell\.nix driver passes it as every package’s configure flags,
the nixpkgs driver makes it the cross package set’s toolchain
outright\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.toolchain\.package



The toolchain itself\. The nixpkgs driver also makes it a
setup dependency of every package, so that a setup hook
exporting ` CC `, ` AR ` and friends is honored\.



*Type:*
null or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.toolchain\.ar



The archiver’s name in the toolchain’s ` bin `, passed to cabal
as ` --with-ar `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"llvm-ar"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.toolchain\.cc



The C compiler’s name in the toolchain’s ` bin `, passed to
cabal as ` --with-gcc `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"wasm32-wasi-clang"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.toolchain\.ld



The linker’s name in the toolchain’s ` bin `, passed to cabal
as ` --with-ld `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"wasm-ld"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.toolchain\.strip



The strip utility’s name in the toolchain’s ` bin `, passed to
cabal as ` --with-strip `\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"llvm-strip"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler\.version



The compiler’s version\. Both drivers read it off the compiler, for
paths and for ` impl(ghc >= ...) ` conditionals, and the stock
compiler of the same major\.minor\.patch is what the builds that
cannot use the package itself fall back to: the nixpkgs package set
the project is built against, and haskell\.nix’s shell tools\. Worth
setting for a nightly bindist, whose name carries only its series\.



*Type:*
null or string



*Default:*
` null `: the ` version ` of ` package `, else the version in its name



*Example:*

```nix
"9.12.4.20260731"
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



## haskell-nix\.compiler-version



The version of the compiler this driver builds with\. Both drivers
answer to the same name, and each answers for itself: they mirror
` compiler ` separately and fall back to different compilers of their
own, so a project asking what it is building against asks the driver:

```
config.<driver>.compiler-version
```



*Type:*
string



*Default:*
the version ` compiler.version ` states, or the one carried by the
compiler the driver resolves: the package a project brought, or the
one haskell\.nix has under that name

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.cross-compiler



The compiler this driver builds a cross target with, by
` pkgs.pkgsCross ` name\. Both drivers answer to the same name, so a
step that needs the compiler an artifact was built with, as
` wasm-jsffi ` does, asks for it the same way whichever driver built
the artifact:

```
config.<driver>.cross-compiler "wasi32"
```



*Type:*
function that evaluates to a(n) package



*Default:*

```
platform:
  config."haskell-nix".project.projectCross.<platform>.pkg-set.config.ghc.package
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.cross-exe



What this driver builds an executable into, for one cross target\. Both
drivers answer to the same name, and what they answer with carries the
executable at ` bin/<exe> `, with a wasm target’s binary at
` bin/<exe>.wasm ` and a javascript target’s linked directory at
` bin/<exe>.jsexe `\. It is what ` bundles ` optimizes\.



*Type:*
function that evaluates to a(n) package



*Default:*

```
{ platform, package, exe }:
  config."haskell-nix".project.projectCross.<platform>
    .hsPkgs.<package>.components.exes.<exe>
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



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



What the overlay adds to that package set: the compilers, the hackage
index, and the ` project ` function the driver calls with
` haskell-nix.options `\.



*Type:*
raw value



*Default:*

```
config."haskell-nix".nixpkgs.haskell-nix
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.input



The haskell\.nix checkout this driver builds with, imported for
` system `\. Everything else the driver uses is taken out of it: the
nixpkgs it pins, the overlay that builds a project, and the helpers
for selecting components\.



*Type:*
raw value



*Default:*

```
import config.inputs."haskell-nix" { inherit system; }
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.lib



haskell\.nix’s own helpers, ` haskellLib `: selecting a project’s local
packages, collecting components and checks, and the compiler
plumbing a bespoke compiler needs\.



*Type:*
raw value



*Default:*

```
config."haskell-nix".haskell-nix.haskellLib
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.nixpkgs



The package set the driver builds with, and the one every native
tool in its shell comes from\.



*Type:*
raw value



*Default:*

```
import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs)
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.nixpkgsArgs



The arguments that nixpkgs is imported with: haskell\.nix’s own
overlays, which is what puts ` haskell-nix ` into the package set, and
the configuration its compilers are built under\.



*Type:*
raw value



*Default:*

```
config."haskell-nix".input.nixpkgsArgs
```

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.nixpkgsSource



The nixpkgs this driver builds from, which is the one haskell\.nix
pins rather than the project’s ` inputs.nixpkgs `: haskell\.nix’s
overlays and its compilers are written against that revision\. The
nixpkgs driver is the one that follows the project’s pin\.



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



The built project as haskell\.nix returns it: ` hsPkgs `, ` shell `,
` projectCross ` per cross platform, ` plan-nix `, and the rest\. Its
shell is the one haskell\.nix builds with the common
` shell.shellHook ` appended and ` shell.withHoogle ` applied, both
through ` overrideAttrs `, so that neither is evaluated unless the
shell is\.



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



## js-optimize



A linked ` .jsexe ` directory with its ` all.js ` closure-compiled, the rest
of the directory as it was\. It takes the directory rather than the
package that carries it:

```
js-optimize {
  platform = "ghcjs";
  package = "frontend";
  exe = "frontend";
  jsexe = "${frontend}/bin/frontend.jsexe";
}
```

The three names are only what the settings are looked up under, and any
of them can be left out to say nothing about it\. ` closure ` is read from
the layer that states a field most specifically to the least:
` platforms.<platform>.packages.<package>.components.exes.<exe>.closure `,
` platforms.<platform>.packages.<package>.closure `,
` platforms.<platform>.closure `, then the same package and executable
layers of ` packages `, and last ` closure ` itself, which is the only one
holding values throughout\. They are read from the project’s own values
rather than a driver’s, since this runs on a built artifact, outside
any driver\.



*Type:*
function that evaluates to a(n) package



*Default:*

```
<nix-haskell>/libs/closure.nix, run with the settings the named target,
package and executable resolve to
```

*Declared by:*
 - [<nix-haskell>/modules/cross/ghcjs](file://<nix-haskell>/modules/cross/ghcjs)



## name



Optional name for better error messages\.



*Type:*
null or string



*Default:*

```nix
"mg7202kynwlydq7c9ghvmfkbh69pmk0l-source"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## nixpkgs\.compiler-version



The version of the compiler this driver builds with\. Both drivers
answer to the same name, and each answers for itself: they mirror
` compiler ` separately and fall back to different compilers of their
own, so a project asking what it is building against asks the driver:

```
config.<driver>.compiler-version
```



*Type:*
string



*Default:*
the version ` compiler.version ` states, or the one carried by the
compiler the driver resolves: the package a project brought, or the
` ghc ` of the package set it selected

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.cross-compiler



The compiler this driver builds a cross target with, by
` pkgs.pkgsCross ` name\. Both drivers answer to the same name, so a
step that needs the compiler an artifact was built with, as
` wasm-jsffi ` does, asks for it the same way whichever driver built
the artifact:

```
config.<driver>.cross-compiler "wasi32"
```



*Type:*
function that evaluates to a(n) package



*Default:*

```
platform: config.nixpkgs.project.projectCross.<platform>.haskellPackages.ghc
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.cross-exe



What this driver builds an executable into, for one cross target\. Both
drivers answer to the same name, and what they answer with carries the
executable at ` bin/<exe> `, with a wasm target’s binary at
` bin/<exe>.wasm ` and a javascript target’s linked directory at
` bin/<exe>.jsexe `\. It is what ` bundles ` optimizes\.

This driver builds one derivation per package, so the executable’s own
name says nothing about where to look; it is taken for the sake of the
one interface both drivers answer to\.



*Type:*
function that evaluates to a(n) package



*Default:*

```
{ platform, package, exe }:
  config.nixpkgs.project.projectCross.<platform>.packages.<package>
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.haskellPackages



The base Haskell package set, before the project’s packages and
overrides are layered on top\.



*Type:*
raw value



*Default:*

```
config.nixpkgs.pkgs.haskell.packages.${config.nixpkgs.compiler.name}
```

A compiler package replaces that set’s ` ghc ` instead, preferring
the set of its own major\.minor\.patch version\.

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



## nixpkgs\.options\.cross-package-defaults



Defaults applied to every package of a cross set the driver
builds itself, the one a compiler bringing its own toolchain
needs (` nixpkgs.pkgsCross `)\. They sit under the project’s own
` packages.<name> ` settings, which the driver layers on after\.
Tests and benchmarks are not among them: a cross set has no
way to run what it builds, so they are always off there\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.cross-package-defaults\.haddock



Build documentation\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.cross-package-defaults\.jailbreak



Lift version bounds (` haskell.lib.doJailbreak `)\. A cross
set has no solver to satisfy them with\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.cross-package-defaults\.profiling



Build profiling libraries\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [<nix-haskell>/modules/nixpkgs](file://<nix-haskell>/modules/nixpkgs)



## nixpkgs\.options\.exact-configuration



Tell Cabal every direct dependency, by the id its package
database records, and every flag the package declares, so it
resolves nothing itself\. It then reads no version bound, which
is what lets a package build against a compiler its cabal file
was written before, including where the bound sits inside a
conditional stanza and ` jailbreak ` cannot reach it\. This is how
the haskell\.nix driver configures every package, which is why
` allow-newer ` in a cabal\.project takes effect there and not
here\.

A flag the project states in ` packages.<name>.flags ` still
decides: the generated assignments go first, and Cabal takes the
last one given\.



*Type:*
boolean



*Default:*

```nix
false
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
A tool is looked up here first, then as ` pkgs.<name> `, then in
the Haskell package set; version requests are ignored, since
nixpkgs carries a single version\. ` cabal ` is here because the
tool’s name is not the name of the package carrying it; an
entry of the project’s own replaces it\.



*Type:*
attribute set of package



*Default:*

```
{ cabal = config.nixpkgs.pkgs.cabal-install; }
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



## nixpkgs\.pkgsCross



Cross package sets for ` project.projectCross `, keyed by
` pkgs.pkgsCross ` platform name\. An entry replaces the package set
the driver would otherwise take from ` pkgs.pkgsCross `, which is
what a compiler bringing its own toolchain needs, since that
toolchain has to become the whole set’s\.



*Type:*
attribute set of raw value



*Default:*

```
<nix-haskell>/libs/nixpkgs/cross-pkgs.nix
```

for every ` compiler.platforms ` entry carrying a ` toolchain `: a
package set for that platform whose whole toolchain is the
compiler’s own, built non-static so that the compiler’s shared
libraries can be used\. A platform without an entry gets none, and
the driver falls back to ` pkgs.pkgsCross.<platform> `\.

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



## platforms



Per-platform customization, keyed by ` pkgs.pkgsCross ` platform name
(the keys of ` shell.crossPlatforms ` and ` projectCross `)\.

A cabal file or project file can make a package’s flags, and through
them its dependencies, conditional on the platform\. The haskell\.nix
driver follows those conditionals through its solver; the nixpkgs
driver has none, so what they would have decided is given here\. The
flags reach the point where a package’s dependencies are worked out,
rather than only how it is configured\.

` wasm-opt ` and ` closure ` are the bundle optimizer settings for whatever
is built for this target, which the ` packages ` entries under them
narrow to one package, and their ` components.exes ` entries to one
executable of it\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```
{
  wasi32.wasm-opt.level = "z";
  wasi32.packages.reflex-dom.flags.use-warp = false;
}
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages



Per-package customization for this platform only, merged over the
project-wide ` packages `\. The fields are the same, with ` bundles `
added: what a driver built for this target, shipped\.



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



## platforms\.\<name>\.packages\.\<name>\.enableDeadCodeElimination



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



## platforms\.\<name>\.packages\.\<name>\.enableLibraryForGhci



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



## platforms\.\<name>\.packages\.\<name>\.enableLibraryProfiling



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



## platforms\.\<name>\.packages\.\<name>\.enableProfiling



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



## platforms\.\<name>\.packages\.\<name>\.enableSeparateDataOutput



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



## platforms\.\<name>\.packages\.\<name>\.enableShared



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



## platforms\.\<name>\.packages\.\<name>\.enableStatic



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



## platforms\.\<name>\.packages\.\<name>\.bundles



What this package’s executables are shipped as for this
target, keyed by the name each carries in
` components.exes `, so that they can be read together
without naming one again\.



*Type:*
attribute set of (submodule)



*Default:*
one entry per executable named under ` components.exes `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.bundles\.\<name>\.jsffi



The ` ghc_wasm_jsffi.js ` this target’s binary cannot be instantiated
without, read out of the binary as linked rather than out of
` optimized `, which has had the sections it reads stripped\. ` null ` off
a wasm target\.



*Type:*
null or package



*Default:*
` wasm-jsffi ` on the executable this driver built, with the compiler it
was built with

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.bundles\.\<name>\.optimized



What gets shipped: the executable a driver built for this target, put
through that target’s optimizer\. ` null ` for a target that has
neither, and ` null ` anywhere but through a driver\.



*Type:*
null or package



*Default:*
the executable this driver built for this target, through
` wasm-optimize ` or ` js-optimize `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.closure\.enable



Whether ` js-optimize ` runs closure-compiler at all\. When false it
copies the jsexe through unchanged\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.closure\.externs



Files passed as ` --externs `, declaring what the program reaches by a
name the compiler must not rename\. The jsexe’s own ` all.externs.js ` is
always passed ahead of these, since ADVANCED renames everything it is
not told the runtime knows by name\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of absolute path)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.closure\.extraFlags



Flags appended after the level and the externs, so one of these decides
what they would have\. One flag per element, its value in the same
string, since the elements are joined into one command line\.

The default accepts whatever syntax the linker emitted, keeps the
compiler quiet, wraps the program in a function expression it may
assume nothing escapes from, asks for strict mode, and stops it
complaining about the names the runtime defines elsewhere\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.closure\.level



The ` --compilation_level ` closure-compiler runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “BUNDLE”, “WHITESPACE_ONLY”, “SIMPLE”, “TRANSPILE_ONLY”, “ADVANCED”



*Default:*

```nix
null
```



*Example:*

```nix
"SIMPLE"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components



Per-component customization, under the kind cabal knows the
component by\. Only executables carry anything so far\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes



Bundle optimizer settings for one executable of the package,
keyed by the name cabal gives it\. They sit under an executable
rather than the package because a bundle is what an executable
links to, and a package can carry several\.

Naming an executable here is also what tells the haskell\.nix
driver to install that executable’s ` .jsexe ` directory, which
it otherwise leaves in the build tree\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.bundles\.jsffi



The ` ghc_wasm_jsffi.js ` this target’s binary cannot be instantiated
without, read out of the binary as linked rather than out of
` optimized `, which has had the sections it reads stripped\. ` null ` off
a wasm target\.



*Type:*
null or package



*Default:*
` wasm-jsffi ` on the executable this driver built, with the compiler it
was built with

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.bundles\.optimized



What gets shipped: the executable a driver built for this target, put
through that target’s optimizer\. ` null ` for a target that has
neither, and ` null ` anywhere but through a driver\.



*Type:*
null or package



*Default:*
the executable this driver built for this target, through
` wasm-optimize ` or ` js-optimize `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.closure\.enable



Whether ` js-optimize ` runs closure-compiler at all\. When false it
copies the jsexe through unchanged\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.closure\.externs



Files passed as ` --externs `, declaring what the program reaches by a
name the compiler must not rename\. The jsexe’s own ` all.externs.js ` is
always passed ahead of these, since ADVANCED renames everything it is
not told the runtime knows by name\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of absolute path)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.closure\.extraFlags



Flags appended after the level and the externs, so one of these decides
what they would have\. One flag per element, its value in the same
string, since the elements are joined into one command line\.

The default accepts whatever syntax the linker emitted, keeps the
compiler quiet, wraps the program in a function expression it may
assume nothing escapes from, asks for strict mode, and stops it
complaining about the names the runtime defines elsewhere\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.closure\.level



The ` --compilation_level ` closure-compiler runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “BUNDLE”, “WHITESPACE_ONLY”, “SIMPLE”, “TRANSPILE_ONLY”, “ADVANCED”



*Default:*

```nix
null
```



*Example:*

```nix
"SIMPLE"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.wasm-opt\.enable



Whether ` wasm-optimize ` runs wasm-opt and the strip that follows it at
all\. When false it copies its input through, so what a caller installs
sits in the same place either way\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.wasm-opt\.extraFlags



Flags appended after ` -all -O<level> `, so one of these decides what the
level would have\. One flag per element, its value in the same string,
since the elements are joined into one command line\.

The default asks for the optimize level of ` -O2 ` at the shrink level of
` -O1 `, drops the memory a module never reads, discards debug
information, and repeats the passes until they stop finding anything\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.components\.exes\.\<name>\.wasm-opt\.level



The ` -O ` level wasm-opt runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “0”, “1”, “2”, “3”, “4”, “s”, “z”



*Default:*

```nix
null
```



*Example:*

```nix
"z"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.configureFlags



Extra flags passed to ` Setup configure `\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.doCheck



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



## platforms\.\<name>\.packages\.\<name>\.doCoverage



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



## platforms\.\<name>\.packages\.\<name>\.doHaddock



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



## platforms\.\<name>\.packages\.\<name>\.doHoogle



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



## platforms\.\<name>\.packages\.\<name>\.doHyperlinkSource



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



## platforms\.\<name>\.packages\.\<name>\.doQuickjump



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



## platforms\.\<name>\.packages\.\<name>\.dontStrip



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



## platforms\.\<name>\.packages\.\<name>\.flags



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



## platforms\.\<name>\.packages\.\<name>\.ghcOptions



GHC flags for this package only\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.hardeningDisable



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



## platforms\.\<name>\.packages\.\<name>\.patches



Patches applied to the package source\.



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.postBuild



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



## platforms\.\<name>\.packages\.\<name>\.postCheck



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



## platforms\.\<name>\.packages\.\<name>\.postConfigure



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



## platforms\.\<name>\.packages\.\<name>\.postHaddock



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



## platforms\.\<name>\.packages\.\<name>\.postInstall



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



## platforms\.\<name>\.packages\.\<name>\.postPatch



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



## platforms\.\<name>\.packages\.\<name>\.postUnpack



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



## platforms\.\<name>\.packages\.\<name>\.preBuild



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



## platforms\.\<name>\.packages\.\<name>\.preCheck



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



## platforms\.\<name>\.packages\.\<name>\.preConfigure



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



## platforms\.\<name>\.packages\.\<name>\.preHaddock



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



## platforms\.\<name>\.packages\.\<name>\.preInstall



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



## platforms\.\<name>\.packages\.\<name>\.prePatch



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



## platforms\.\<name>\.packages\.\<name>\.preUnpack



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



## platforms\.\<name>\.packages\.\<name>\.profilingDetail



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



## platforms\.\<name>\.packages\.\<name>\.setupBuildFlags



Extra flags passed to ` Setup build `\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.setupHaddockFlags



Extra flags passed to ` Setup haddock `\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.src



Replacement source for the package\.



*Type:*
null or absolute path or package



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.wasm-opt\.enable



Whether ` wasm-optimize ` runs wasm-opt and the strip that follows it at
all\. When false it copies its input through, so what a caller installs
sits in the same place either way\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.wasm-opt\.extraFlags



Flags appended after ` -all -O<level> `, so one of these decides what the
level would have\. One flag per element, its value in the same string,
since the elements are joined into one command line\.

The default asks for the optimize level of ` -O2 ` at the shrink level of
` -O1 `, drops the memory a module never reads, discards debug
information, and repeats the passes until they stop finding anything\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.packages\.\<name>\.wasm-opt\.level



The ` -O ` level wasm-opt runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “0”, “1”, “2”, “3”, “4”, “s”, “z”



*Default:*

```nix
null
```



*Example:*

```nix
"z"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.closure\.enable



Whether ` js-optimize ` runs closure-compiler at all\. When false it
copies the jsexe through unchanged\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.closure\.externs



Files passed as ` --externs `, declaring what the program reaches by a
name the compiler must not rename\. The jsexe’s own ` all.externs.js ` is
always passed ahead of these, since ADVANCED renames everything it is
not told the runtime knows by name\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of absolute path)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.closure\.extraFlags



Flags appended after the level and the externs, so one of these decides
what they would have\. One flag per element, its value in the same
string, since the elements are joined into one command line\.

The default accepts whatever syntax the linker emitted, keeps the
compiler quiet, wraps the program in a function expression it may
assume nothing escapes from, asks for strict mode, and stops it
complaining about the names the runtime defines elsewhere\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.closure\.level



The ` --compilation_level ` closure-compiler runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “BUNDLE”, “WHITESPACE_ONLY”, “SIMPLE”, “TRANSPILE_ONLY”, “ADVANCED”



*Default:*

```nix
null
```



*Example:*

```nix
"SIMPLE"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.wasm-opt\.enable



Whether ` wasm-optimize ` runs wasm-opt and the strip that follows it at
all\. When false it copies its input through, so what a caller installs
sits in the same place either way\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.wasm-opt\.extraFlags



Flags appended after ` -all -O<level> `, so one of these decides what the
level would have\. One flag per element, its value in the same string,
since the elements are joined into one command line\.

The default asks for the optimize level of ` -O2 ` at the shrink level of
` -O1 `, drops the memory a module never reads, discards debug
information, and repeats the passes until they stop finding anything\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or (list of string)



*Default:*

```nix
null
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## platforms\.\<name>\.wasm-opt\.level



The ` -O ` level wasm-opt runs at\.

` null ` states nothing, leaving the field to the layer beneath it, and last to the tool’s own settings at the top level\.



*Type:*
null or one of “0”, “1”, “2”, “3”, “4”, “s”, “z”



*Default:*

```nix
null
```



*Example:*

```nix
"z"
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



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



The project source: the tree holding the cabal project file and the
packages it names\. A path is copied into the store, filtered first
when ` clean-src ` is enabled; a derivation or a store path is used as
it is, on the grounds that whatever produced it already chose what it
contains\.



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
    ignoreFiles = config.clean-src-ignore-files;
    patterns = config.clean-src-patterns;
  }
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## system



The system the project is built on\. Each driver instantiates its
package set for it, and a cross target is named relative to it\.



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



## wasm-jsffi



The ` ghc_wasm_jsffi.js ` a GHC-built wasm module needs to be
instantiated at all, read out of the binary by the compiler that built
it:

```
wasm-jsffi {
  ghc = config.<driver>.cross-compiler "wasi32";
  wasm = "${frontend}/bin/frontend.wasm";
}
```

The compiler must be the one that produced the binary, which is what
` <driver>.cross-compiler ` names\. Run this on the binary as linked,
before ` wasm-optimize ` strips the sections it reads\.



*Type:*
function that evaluates to a(n) package



*Default:*

```
<nix-haskell>/libs/wasm-jsffi.nix
```

*Declared by:*
 - [<nix-haskell>/modules/cross/wasm](file://<nix-haskell>/modules/cross/wasm)



## wasm-opt\.enable



Whether ` wasm-optimize ` runs wasm-opt and the strip that follows it at
all\. When false it copies its input through, so what a caller installs
sits in the same place either way\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [<nix-haskell>/modules/cross/wasm](file://<nix-haskell>/modules/cross/wasm)



## wasm-opt\.extraFlags



Flags appended after ` -all -O<level> `, so one of these decides what the
level would have\. One flag per element, its value in the same string,
since the elements are joined into one command line\.

The default asks for the optimize level of ` -O2 ` at the shrink level of
` -O1 `, drops the memory a module never reads, discards debug
information, and repeats the passes until they stop finding anything\.



*Type:*
list of string



*Default:*

```nix
[
  "-ol 2"
  "-s 1"
  "--low-memory-unused"
  "--strip-dwarf"
  "--converge"
]
```

*Declared by:*
 - [<nix-haskell>/modules/cross/wasm](file://<nix-haskell>/modules/cross/wasm)



## wasm-opt\.level



The ` -O ` level wasm-opt runs at\.



*Type:*
one of “0”, “1”, “2”, “3”, “4”, “s”, “z”



*Default:*

```nix
"2"
```



*Example:*

```nix
"z"
```

*Declared by:*
 - [<nix-haskell>/modules/cross/wasm](file://<nix-haskell>/modules/cross/wasm)



## wasm-optimize



A wasm binary optimized and stripped\. It takes the file rather than the
package that carries it, and yields the file rather than a directory
holding it, so the caller installs it under whatever name it wants:

```
wasm-optimize {
  platform = "wasi32";
  package = "frontend";
  exe = "frontend";
  wasm = "${frontend}/bin/frontend.wasm";
}
```

The three names are only what the settings are looked up under, and any
of them can be left out to say nothing about it\. ` wasm-opt ` is read
from the layer that states a field most specifically to the least:
` platforms.<platform>.packages.<package>.components.exes.<exe>.wasm-opt `,
` platforms.<platform>.packages.<package>.wasm-opt `,
` platforms.<platform>.wasm-opt `, then the same package and executable
layers of ` packages `, and last ` wasm-opt ` itself, which is the only one
holding values throughout\. They are read from the project’s own values
rather than a driver’s, since this runs on a built artifact, outside
any driver\.



*Type:*
function that evaluates to a(n) package



*Default:*

```
<nix-haskell>/libs/wasm-opt.nix, run with the settings the named target,
package and executable resolve to
```

*Declared by:*
 - [<nix-haskell>/modules/cross/wasm](file://<nix-haskell>/modules/cross/wasm)



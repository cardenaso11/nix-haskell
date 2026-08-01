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

*Declared by:*
 - [\<nixpkgs/lib/modules\.nix>](https://github.com/NixOS/nixpkgs/blob//lib/modules.nix)



## cabalProject



Content of the ` cabal.project ` file\. Passed through to haskell\.nix\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## cabalProjectFileName



Name of the cabal project file\. Passed through to haskell\.nix\.



*Type:*
string



*Default:*
` "cabal.project" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## cabalProjectFreeze



Content of the ` cabal.project.freeze ` file\. Passed through to haskell\.nix\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## cabalProjectLocal



Content of the ` cabal.project.local ` file\. Passed through to haskell\.nix\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

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
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## clean-src-patterns



Extra gitignore-syntax patterns applied on top of the tree’s own
` .gitignore ` when ` clean-src ` is enabled\. Useful for artifacts that only
a nested ` .gitignore ` lists, since those patterns are not read\.



*Type:*
strings concatenated with “\\n”



*Default:*
` "" `



*Example:*

```
''
  dist-wasm
  dist-js
''
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## compiler-nix-name



The name of the ghc compiler to use\.



*Type:*
string



*Default:*
` "ghc914" `



*Example:*
` "ghc884" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## extra-hackage-tarballs



Additional Hackage tarball indices to pass to haskell\.nix\. Automatically includes tarballs from ` hackage-overlays ` when set\.



*Type:*
null or (attribute set)



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## extra-hackages



Additional Hackage package sets for the cabal solver\. Automatically includes packages from ` hackage-overlays ` when set\.



*Type:*
null or (list of unspecified value)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## extraCabalProject



Lines to append to ` cabal.project `\.



*Type:*
list of strings concatenated with “\\n”



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## extraSrcFiles



ExtraSrcFiles to include in the project builds



*Type:*
attribute set



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## hackage-driver



Internal driver that generates a fake Hackage index from ` hackage-overlays `\.



*Type:*
attribute set *(read only)*



*Default:*

```
  import ../libs/hackage-driver.nix {
    pkgs = config."haskell-nix".nixpkgs;
    compiler-nix-name = config.compiler-nix-name;
    modules = config.hackage-overlays;
  };
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## hackage-overlays



Overlays for hackage, to pass to the cabal solver\.

This will automatically pull and put the defined packages into a “fake” hackage\. This allows the cabal solver see packages that can’t be conventially added to cabal\.project\.
A good example of this is obelisk-generated-static\.

This is a purely helper-code for the nix-side of haskell\.nix



*Type:*
list of (attribute set)



*Default:*
` [ ] `



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
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.cabalProject



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.cabalProjectFileName



This option has no description\.



*Type:*
string



*Default:*
` "cabal.project" `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.cabalProjectFreeze



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.cabalProjectLocal



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.checkMaterialization



If true the nix files will be generated used to check plan-sha256 and material



*Type:*
null or boolean



*Default:*
` null `

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
` <function> `

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
` "" `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.crossPlatforms



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

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
` <nix-haskell> `

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
` "x86_64-linux" `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.extra-hackage-tarballs



This option has no description\.



*Type:*
null or (attribute set)



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.extra-hackages



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake



Default arguments to use for the ` p.flake `\.



*Type:*
submodule



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.packages



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.coverageProjectModule



Project module for use when generating coverage reports\.
The project packages will have ` packages.X.doCoverage `
turned on by default\.



*Type:*
unspecified value



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.crossPlatforms



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.flake\.doCoverage



Specifies if the flake ` ciJobs ` and ` hydraJobs ` should include code
coverage reports\.



*Type:*
boolean



*Default:*
` false `

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
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.ghc



Deprecated in favour of ` compiler-nix-name `



*Type:*
null or package



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.ghcOverride



Used when we need to set ghc explicitly during bootstrapping



*Type:*
null or package



*Default:*
` null `

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
` false `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.index-sha256



The hash of the truncated hackage index-state



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.index-state



Hackage index-state, eg\. “2019-10-10T00:00:00Z”



*Type:*
null or string



*Default:*
` null `

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
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.materialized



Location of a materialized copy of the nix files



*Type:*
null or absolute path or package



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.modules



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.name



Optional name for better error messages



*Type:*
null or string



*Default:*
` "haskell-project" `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.nix-tools



nix-tools to use when converting the ` plan.json ` to nix



*Type:*
null or package



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.pkg-def-extras



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.plan-sha256



The hash of the plan-to-nix output (makes the plan-to-nix step a fixed output derivation)



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.prebuilt-depends



pre-built (perhaps proprietary) Haskell packages to make available as dependencies

See Note \[prebuilt dependencies] for more details



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.projectFileName



This option has no description\.



*Type:*
null or string



*Default:*
` null `

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

```
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
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.enableDWARF



This option has no description\.



*Type:*
unspecified value



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.packageSetupDeps



This option has no description\.



*Type:*
unspecified value



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.packages



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.additional



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

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
` true `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.buildInputs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.components



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.crossPlatforms



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.exactDeps



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.inputsFrom



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.name



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.nativeBuildInputs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.passthru



This option has no description\.



*Type:*
attribute set of unspecified value



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.shellHook



This option has no description\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.tools



This option has no description\.



*Type:*
attribute set of unspecified value



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.withHaddock



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.shell\.withHoogle



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/haskell\.nix](file://<nix-haskell>/modules/haskell.nix)



## haskell-nix\.options\.source-repo-override



This option has no description\.



*Type:*
attribute set of function that evaluates to a(n) (attribute set)



*Default:*
` { } `

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
` false `

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



## index-state



Hackage index-state\.



*Type:*
null or string



*Default:*
` null `



*Example:*
` "2019-10-10T00:00:00Z" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## inputMap



Specifies the contents of urls in the cabal\.project file\.
The ` .rev ` attribute is checked against the ` tag ` for ` source-repository-packages `\.



*Type:*
attribute set



*Default:*
` { } `



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
` { } `

*Declared by:*
 - [<nix-haskell>/modules/inputs\.nix](file://<nix-haskell>/modules/inputs.nix)



## isGhcjs



Whether the project targets GHCJS (either natively or via cross-compilation)\.
Used to conditionally include JavaScript runtime dependencies\.



*Type:*
boolean



*Default:*

```
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

```
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



## modules



` modules ` option definitions (readonly)\. To actually change them use ` overrides `\.



*Type:*
list of (submodule) *(read only)*



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.package-keys



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.packages



This option has no description\.



*Type:*
attribute set of (submodule)

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.packages\.\<name>\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.package\.author



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.buildType



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.cleanHpack



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.copyright



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.dataDir



This option has no description\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.dataFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.description



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.detailLevel



This option has no description\.



*Type:*
string



*Default:*
` "MinimalDetails" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.extraDocFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.extraSrcFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.extraTmpFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.homepage



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.identifier\.id



This option has no description\.



*Type:*
string



*Default:*
` "\${config.package.identifier.name}-\${config.package.identifier.version}" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.identifier\.name



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.identifier\.version



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.isLocal



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.isProject



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.isRedirect



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.license



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.licenseFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.maintainer



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.setup-depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.specVersion



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.synopsis



This option has no description\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package\.url



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.package-description-override



Cabal file to use instead of the one shipped inside the package source distribution\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.allComponent



The merged dependencies of all other components



*Type:*
submodule

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.asmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.build-tools



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.cSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.cmmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.cxxSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.extraSrcFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.frameworks



This option has no description\.



*Type:*
list of (null or package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.hsSourceDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```
[
  "."
]
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.includeDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.includes



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.jsSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.libs



This option has no description\.



*Type:*
list of (null or package or list of package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.mainPath



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.modules



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.pkgconfig



This option has no description\.



*Type:*
list of list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.platforms



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.plugins



This option has no description\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.plugins\.\*\.args



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.plugins\.\*\.library



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.plugins\.\*\.moduleName



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.pre-existing



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.allComponent\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.cabal-generator



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks

This option has no description\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.asmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.build-tools



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.cSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.cmmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.cxxSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.extraSrcFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.frameworks



This option has no description\.



*Type:*
list of (null or package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.hsSourceDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```
[
  "."
]
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.includeDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.includes



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.jsSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.libs



This option has no description\.



*Type:*
list of (null or package or list of package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.mainPath



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.modules



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.pkgconfig



This option has no description\.



*Type:*
list of list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.platforms



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.plugins



This option has no description\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.plugins\.\*\.args



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.plugins\.\*\.library



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.plugins\.\*\.moduleName



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.pre-existing



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.benchmarks\.\<name>\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes



This option has no description\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.enableProfiling

This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.asmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.build-tools



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.cSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.cmmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.cxxSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.extraSrcFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.frameworks



This option has no description\.



*Type:*
list of (null or package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.hsSourceDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```
[
  "."
]
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.includeDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.includes



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.jsSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.libs



This option has no description\.



*Type:*
list of (null or package or list of package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.mainPath



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.modules



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.pkgconfig



This option has no description\.



*Type:*
list of list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.platforms



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.plugins



This option has no description\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.plugins\.\*\.args



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.plugins\.\*\.library



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.plugins\.\*\.moduleName



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.pre-existing



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.exes\.\<name>\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs



This option has no description\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.asmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.build-tools



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.cSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.cmmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.cxxSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.extraSrcFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.frameworks



This option has no description\.



*Type:*
list of (null or package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.hsSourceDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```
[
  "."
]
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.includeDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.includes



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.jsSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.libs



This option has no description\.



*Type:*
list of (null or package or list of package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.mainPath



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.modules



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.pkgconfig



This option has no description\.



*Type:*
list of list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.platforms



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.plugins



This option has no description\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.plugins\.\*\.args



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.plugins\.\*\.library



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.plugins\.\*\.moduleName



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.postCheck

This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.pre-existing



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.foreignlibs\.\<name>\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library



This option has no description\.



*Type:*
null or (submodule)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.asmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.build-tools



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.cSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.cmmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.cxxSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.extraSrcFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.frameworks



This option has no description\.



*Type:*
list of (null or package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.hsSourceDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```
[
  "."
]
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.includeDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.includes



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.jsSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.libs



This option has no description\.



*Type:*
list of (null or package or list of package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.mainPath



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.modules



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.pkgconfig



This option has no description\.



*Type:*
list of list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.platforms



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.plugins



This option has no description\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.plugins\.\*\.args



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.plugins\.\*\.library



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.plugins\.\*\.moduleName



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.pre-existing



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.library\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup



This option has no description\.



*Type:*
null or (submodule)



*Default:*

```
{
  asmSources = [ ];
  cSources = [ ];
  cmmSources = [ ];
  cxxSources = [ ];
  depends = [ ];
  doExactConfig = false;
  extraSrcFiles = [
    "Setup.hs"
    "Setup.lhs"
  ];
  frameworks = [ ];
  hsSourceDirs = [
    "setup-src"
  ];
  includeDirs = [ ];
  jsSources = [ ];
  libs = [ ];
  platforms = null;
}
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.asmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.build-tools



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.cSources

This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.cmmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.cxxSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.extraSrcFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.frameworks



This option has no description\.



*Type:*
list of (null or package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.hsSourceDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```
[
  "."
]
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.includeDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.includes



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.jsSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.libs



This option has no description\.



*Type:*
list of (null or package or list of package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.mainPath



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.modules



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.pkgconfig



This option has no description\.



*Type:*
list of list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.platforms



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.plugins



This option has no description\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.plugins\.\*\.args



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.plugins\.\*\.library



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.plugins\.\*\.moduleName



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.pre-existing



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.setup\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs



This option has no description\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.asmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.build-tools



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.cSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.cmmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.cxxSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.extraSrcFiles

This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.frameworks



This option has no description\.



*Type:*
list of (null or package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.hsSourceDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```
[
  "."
]
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.includeDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.includes



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.jsSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.libs



This option has no description\.



*Type:*
list of (null or package or list of package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.mainPath



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.modules



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.pkgconfig



This option has no description\.



*Type:*
list of list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.platforms



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.plugins



This option has no description\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.plugins\.\*\.args



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.plugins\.\*\.library



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.plugins\.\*\.moduleName



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.pre-existing



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.sublibs\.\<name>\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests



This option has no description\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.enableDeadCodeElimination



If set, enables split sections for link-time dead-code stripping\. Only applies to Linux



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.enableExecutableDynamic



If set, links executables against shared libraries\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.enableLibraryForGhci



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.enableLibraryProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.enableProfiling



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.enableSeparateDataOutput



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.enableShared



If set, enables building shared libraries\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.enableStatic



If set, enables building static libraries and executables\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.asmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.build-tools



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.cSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.cmmSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.cxxSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.depends



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.extraSrcFiles



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.frameworks



This option has no description\.



*Type:*
list of (null or package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.hsSourceDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*

```
[
  "."
]
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.includeDirs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.includes



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.jsSources



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.libs



This option has no description\.



*Type:*
list of (null or package or list of package)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.mainPath



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.modules



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.pkgconfig



This option has no description\.



*Type:*
list of list of package



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.platforms



This option has no description\.



*Type:*
null or (list of unspecified value)



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.plugins



This option has no description\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.plugins\.\*\.args



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.plugins\.\*\.library



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.plugins\.\*\.moduleName



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.postPatch

This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.pre-existing



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.components\.tests\.\<name>\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.doHyperlinkSource



Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.flags



This option has no description\.



*Type:*
attribute set of boolean

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.name



This option has no description\.



*Type:*
string



*Default:*
` "\${config.package.identifier.name}-\${config.package.identifier.version}" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.patches



This option has no description\.



*Type:*
list of (unspecified value or absolute path)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.revision



This option has no description\.



*Type:*
null or signed integer



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.revisionSha256



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.sha256



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.src



This option has no description\.



*Type:*
null or absolute path or package



*Default:*

```
''
  pkgs.fetchurl {
    url = "mirror://hackage/$'{config.name}.tar.gz";
    inherit (config) sha256;
  };
''
```

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package.nix)



## modules\.\*\.packages\.\<name>\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.packages\.\<name>\.testWrapper

A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/package-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/package-options.nix)



## modules\.\*\.packages\.\<name>\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/pins/haskell-nix/modules/component-options\.nix](file://<nix-haskell>/pins/haskell-nix/modules/component-options.nix)



## modules\.\*\.buildable



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.cabal\.compiler



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.cabal\.system



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.compiler\.packages



This option has no description\.



*Type:*
attribute set of string

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.compiler\.nix-name



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.compiler\.version



This option has no description\.



*Type:*
string

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.configureAllComponents



If set all the components in the package are configured (useful for cabal-doctest)\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.configureFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.contentAddressed



Build content addressed derivation, requires Nix to have experimental feature
` ca-derivations ` enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.doCheck



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.doCoverage



Enable production of test coverage reports\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.doCrossCheck



Run doCheck also in cross compilation settings\. This can be tricky as the test logic must know how to run the tests on the target\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.doExactConfig



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.doHaddock



Enable building of the Haddock documentation from the annotated Haskell source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.doHoogle



Also build a hoogle index\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.doHyperlinkSource

Link documentation to the source code\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.doQuickjump



Generate an index for interactive documentation navigation\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.dontPatchELF



If set, the patchelf command is not used to remove unnecessary RPATH entries\. Only applies to Linux\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.dontStrip



If set, libraries and executables are not stripped\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.dontUpdateAutotoolsGnuConfigScripts



If set, config\.sub and config\.guess will not be updated\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.evalPackages



The ` evalPackages ` that will be used when building ` hoogle ` and shell tools\.



*Type:*
unspecified value



*Default:*
` "pkgs.pkgsBuildBuild" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.ghc\.package



This option has no description\.



*Type:*
package



*Default:*
` "pkgs.buildPackages.haskell-nix.compiler.\${config.compiler.nix-name}" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.ghcOptions



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.hackage\.configs



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.hackage\.db



This option has no description\.



*Type:*
unspecified value

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.hardeningDisable



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.keepConfigFiles



Keep component configFiles in the store in a ` configFiles ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.keepGhc



Keep component wrapped ghc in the store in a ` ghc ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.keepSource



Keep component source in the store in a ` source ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.plan-json



This option has no description\.



*Type:*
attribute set of unspecified value

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.planned



Set to true by ` plan-to-nix ` for any component that was included in the ` plan.json ` file\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.postBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.postCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.postConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.postHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.postInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.postPatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.postUnpack



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.preBuild



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.preCheck



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.preConfigure



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.preHaddock



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.preInstall



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.prePatch



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.preUnpack



This option has no description\.



*Type:*
null or strings concatenated with “\\n”



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.profilingDetail



This option has no description\.



*Type:*
null or string



*Default:*
` "default" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.setupBuildFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.setupHaddockFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.setupInstallFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.shellHook



Hook to run when entering a shell



*Type:*
unspecified value



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.testFlags



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.testWrapper



A command to run for executing tests in checkPhase, which takes the original test command as its arguments\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*
` "echo" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.use-package-keys



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## modules\.\*\.writeHieFiles



Write component ` .hie ` files in the store in a ` hie ` output



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## name



Optional name for better error messages\.



*Type:*
null or string



*Default:*
` "q0ra12zkz2sbc8jiwcpa5gd21m9l5ifw-source" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## optimizations\.O2



Enable -O2 optimization level\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.all



Enable all optimization flags\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.cross-module-specialise



Enable -fcross-module-specialise\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.expose-all-unfoldings



Enable -fexpose-all-unfoldings for cross-module optimization\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.late-specialise



Enable -flate-specialise\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.specialise



Enable -fspecialise\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## optimizations\.specialise-aggressively



Enable -fspecialise-aggressively\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/optimizations\.nix](file://<nix-haskell>/modules/optimizations.nix)



## overrides



` modules ` overrides\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## pkg-def-extras



Extra package definition functions to pass to haskell\.nix\.



*Type:*
null or (list of unspecified value)



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## sha256map



An alternative to adding ` --sha256 ` comments into the cabal\.project file\.



*Type:*
null or (attribute set of (string or attribute set of string))



*Default:*
` null `



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



This option has no description\.



*Type:*
submodule

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.enableDWARF



This option has no description\.



*Type:*
unspecified value



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.packageSetupDeps



This option has no description\.



*Type:*
unspecified value



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.packages



Package selection function\. It takes a list of Haskell packages and returns a subset of these packages with all of their dependencies included in ` ghc-pkg list `\.
It can take either a ` package ` or name (` string `) of a package which availability can depend on the platform\.



*Type:*
unspecified value



*Default:*
` <function> `



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



## shell\.additional



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.allToolDeps



Indicates if the shell should include all the tool dependencies
of the haskell packages in the project\.  Defaulted to ` false ` in
stack projects (to avoid trying to build the tools used by
every ` stackage ` package)\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.buildInputs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.components



This option has no description\.



*Type:*
unspecified value



*Default:*
` <function> `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.crossPlatforms



This option has no description\.



*Type:*
unspecified value



*Default:*

```
ps: []
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.exactDeps



This option has no description\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.inputsFrom



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.name



This option has no description\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.nativeBuildInputs



This option has no description\.



*Type:*
list of unspecified value



*Default:*
` [ ] `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.passthru



This option has no description\.



*Type:*
attribute set of unspecified value



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.shellHook



Shell hook to run when entering the shell\.



*Type:*
strings concatenated with “\\n”



*Default:*
` "" `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.tools



This option has no description\.



*Type:*
attribute set of unspecified value



*Default:*
` { } `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.withHaddock



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## shell\.withHoogle



This option has no description\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## source-repository-packages



Local packages to add to the project as ` source-repository-package `
stanzas\. A source is anything ` inputs ` accepts, so a packed thunk
directory can be given as-is and is resolved to the source it pins\.

` subdir ` selects packages within the source, so a multi-package
repository needs one entry rather than one per package\.



*Type:*
attribute set of (absolute path or (attribute set))



*Default:*
` { } `



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



## source-repository-packages-driver



This option has no description\.



*Type:*
attribute set *(read only)*



*Default:*

```
(import ../libs/cabal.nix { inherit pkgs; }).source-repository-packages config.source-repository-packages;
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## src



This option has no description\.



*Type:*
absolute path or package



*Example:*
` "./." `

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



## src-driver



This option has no description\.



*Type:*
absolute path *(read only)*



*Default:*

```
  import ../libs/src-driver.nix {
    inherit pkgs;
    src = config.src-cleaned;
    extraCabalProject =
         [config.source-repository-packages-driver.cabalProject]
      ++ config.extraCabalProject or [];
  };
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



## system



This option has no description\.



*Type:*
string



*Default:*

```
''
  builtins.currentSystem
''
```

*Declared by:*
 - [<nix-haskell>/modules/common\.nix](file://<nix-haskell>/modules/common.nix)



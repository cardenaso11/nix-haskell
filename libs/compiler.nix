# The common `compiler` option interpreted: per-platform resolution to the
# names a build needs and to a compiler derivation carrying the attributes the
# drivers read off it.
#
# Each entry resolves a field first, then whatever the package already carries
# (so a driver's own compilers need no fields at all), then a neutral value.
# Three names come out of it:
#
#   name       the project-wide key: the compiler the driver looks up by name,
#              and the package set whose compiler a package replaces
#   stockName  the driver's own compiler of the same major.minor.patch,
#              derived from the version alone. The builds that cannot use the
#              package itself go here: the nixpkgs package set the project is
#              built against, haskell.nix's shell tools. Deriving it from the
#              version rather than from `name` keeps an overridden name from
#              sending those builds to a set that does not exist.
#   annotated  the package with the attributes spliced back on
#
# Example:
#
#   compilers = import ./compiler.nix { inherit lib; } {
#     compiler = config.compiler;
#     system = "x86_64-linux";
#   };
#   => { native = <entry>; resolve = <key: entry>;
#        targetKey = <targetPlatform: key or null>; anyToolchain = <bool>; }
#   compilers.native
#   => { name = "ghc912"; stockName = "ghc912"; package = null; annotated = null; ... }
#   compilers.resolve "wasi32"
#   => { name = "ghc912"; stockName = "ghc9124"; annotated = <bindist // { ... }>;
#        toolchainFlags = [ "--with-gcc=/nix/store/...-wasi-sdk/bin/wasm32-wasi-clang" ... ]; }
#   compilers.targetKey <elaborated wasi32>    => "wasi32"
#   compilers.targetKey <elaborated x86_64>    => "x86_64-linux"
#   compilers.targetKey <elaborated aarch64>   => null
{ lib }:

{ compiler, system }:

with lib;

let crossPlatform = import ./cross-platform.nix { inherit lib; };

    platforms = compiler.platforms;

    entry = where: spec:
      let package = spec.package;

          version =
            if spec.version != null then spec.version
            else if package == null then null
            else let parsed = getVersion package;
                 in if parsed != "" then parsed
                    else throw ("nix-haskell: cannot derive a version for"
                      + " `compiler${where}` from ${package.name or "<compiler package>"};"
                      + " set `compiler${where}.version`");

          name =
            if spec.name != null then spec.name
            else if version != null then "ghc" + replaceStrings [ "." ] [ "" ] version
            else throw ("nix-haskell: `compiler${where}` has no name and nothing"
              + " to derive one from; set `compiler${where}.name`");

          stockName =
            if version == null then name
            else "ghc" + concatStrings (take 3 (splitVersion version));

          targetPrefix =
            if spec.targetPrefix != null then spec.targetPrefix
            else package.targetPrefix or "";

          enableShared =
            if spec.enableShared != null then spec.enableShared
            else package.enableShared or true;

          libDir = spec.haskell-nix.libDir;

          haskellCompilerName =
            if spec.nixpkgs.haskellCompilerName != null then spec.nixpkgs.haskellCompilerName
            else package.haskellCompilerName or
              (if version == null then null else "ghc-${version}");

          toolchain = spec.toolchain;

          # The cabal flags pointing a build at the compiler's own C tools.
          # One list for both drivers, so a build gets the same toolchain
          # whichever one runs it. A repeated flag is taken by cabal from the
          # last occurrence, which is how these override what a driver passes
          # from the surrounding package set.
          toolchainFlags =
            let flag = cabalName: tool:
                  optional (tool != null)
                    "--with-${cabalName}=${toolchain.package}/bin/${tool}";
            in optionals (toolchain.package != null) (concatLists [
                 (flag "gcc" toolchain.cc)
                 (flag "ar" toolchain.ar)
                 (flag "ld" toolchain.ld)
                 (flag "strip" toolchain.strip)
               ]);

      in {
        inherit name stockName version targetPrefix enableShared package;
        inherit toolchain toolchainFlags;
        inherit (spec.nixpkgs) enableExternalInterpreter;

        annotated =
          if package == null
          then null
          else package
            // { inherit version targetPrefix enableShared; }
            // optionalAttrs (libDir != null) { inherit libDir; }
            // optionalAttrs (haskellCompilerName != null) { inherit haskellCompilerName; };
      };

in rec {

  native = entry "" (removeAttrs compiler [ "platforms" ]);

  # A platform's own entry when it has one, else the compiler above the table.
  # An entry is additive, so an ordinary cross target keeps working with only
  # one compiler declared.
  resolve = key:
    if key == null || ! (platforms ? ${key})
    then native
    else entry ".platforms.${key}" platforms.${key};

  # Whether any entry brings its own toolchain, which is what decides whether
  # a driver needs the toolchain machinery at all.
  anyToolchain =
    native.toolchain.package != null
    || any (spec: spec.toolchain.package != null) (attrValues platforms);

  # The `platforms` key for a target platform, or null when no entry matches
  # and the compiler above the table applies.
  targetKey = targetPlatform:
    let crossKeys = filter (key: key != system) (attrNames platforms);
    in if targetPlatform.system == system
       then system
       else crossPlatform.keyFor crossKeys targetPlatform;

}

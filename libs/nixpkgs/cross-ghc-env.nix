# A cross compiler carrying a package database of the shell's dependencies, so
# cabal in a shell with no hackage index can resolve against what is installed.
#
# nixpkgs' `ghcWithPackages` does the same thing and cannot be used here. It
# joins the compiler and the packages, then reaches into
# `lib/<prefix><haskellCompilerName>/package.conf.d`, a path it builds from the
# version rather than asks for. A relocatable bindist keeps its database
# directly under `lib`, so the join fails outright:
#
#   rm: cannot remove '.../lib/wasm32-wasi-ghc-9.12.4.20260731/package.conf.d/
#       package.cache.lock': No such file or directory
#
# The packages go in a second database instead, and the compiler keeps its
# own. A compiler aimed at another directory with `-B` no longer finds the
# Template Haskell interpreter the wasm backend loads from there, and every
# splice dies with `readPipe: end of file`.
#
# The database holds the closure of the packages given, not only the packages
# themselves. A registration names its dependencies by unit id, and one the
# database lacks breaks the package that names it.
#
# Example:
#
#   import ./cross-ghc-env.nix { inherit pkgs lib; } {
#     ghc = <wasm32-wasi-ghc-9.12, libdir lib, targetPrefix "wasm32-wasi-">;
#     packages = [ <random> ];
#   }
#   => <derivation wasm32-wasi-ghc-with-packages> holding
#
#        bin/wasm32-wasi-ghc      # -package-db <out>/lib/extra-package.conf.d
#        bin/wasm32-wasi-ghc-pkg  # --package-db=<out>/lib/extra-package.conf.d
#        lib/extra-package.conf.d/random-1.2.1.3-....conf    # the package given
#        lib/extra-package.conf.d/splitmix-0.1.1-....conf    # what it needs
#
#      with `targetPrefix` on its passthru, which the wrapper scripts read
#      to name the dispatcher built around this.
#
#   import ./cross-ghc-env.nix { inherit pkgs lib; } {
#     ghc = <wasm32-wasi-ghc-9.12>;
#     packages = [];
#   }
#   => the compiler itself, unwrapped: a database holding only what the
#      compiler already has is one it gains nothing from
{ pkgs, lib }:

{ ghc, packages }:

let prefix = ghc.targetPrefix;

    # Everything the named packages were built against, which is what their
    # registrations name.
    closure = pkgs.closureInfo { rootPaths = packages; };

    # The executables that have to be told about the second database, and how
    # each spells it. Named rather than probed, since the case arms are
    # written before the compiler's `bin` can be listed. Every other tool
    # there is linked through untouched: one that reads no database gains
    # nothing from a wrapper.
    databaseReaders =
      [ { name = "${prefix}ghc-pkg"; flags = "--package-db=@db@"; } ]
      ++ map (name: { inherit name; flags = "-package-db @db@"; })
           ([ "${prefix}ghc" "${prefix}ghci" "${prefix}runghc" "${prefix}runhaskell" ]
            ++ lib.optionals (ghc ? version)
                 [ "${prefix}ghc-${ghc.version}" "${prefix}ghci-${ghc.version}" ]);

    flagCases = lib.concatMapStringsSep "\n"
      (reader: "        ${reader.name}) flags=${lib.escapeShellArg reader.flags} ;;")
      databaseReaders;

in if packages == []
   then ghc
   else pkgs.symlinkJoin {
     name = "${prefix}ghc-with-packages";
     paths = [ ghc ];
     nativeBuildInputs = [ pkgs.makeWrapper ];
     passthru = { inherit (ghc) targetPrefix; }
       // lib.optionalAttrs (ghc ? version) { inherit (ghc) version; };
     postBuild = ''
       # A database beside the compiler's own, rather than one replacing it.
       # The compiler keeps its own directory, which the wasm backend loads
       # its Template Haskell interpreter from: a compiler told to read
       # another directory with `-B` finds no interpreter there and every
       # splice dies with `readPipe: end of file`.
       db=$out/lib/extra-package.conf.d
       mkdir -p "$db"

       # Every registration in the closure, not only the packages named. A
       # registration names its dependencies by unit id, and one the
       # database lacks breaks the package that names it. The closure holds
       # exactly what the named packages were built against.
       #
       # The path filter keeps this target's registrations: a closure also
       # reaches the build platform's, and the two databases are separate.
       #
       # The compiler's own registrations stay where they are. They name
       # their files under `''${pkgroot}`, which resolves beside the database
       # holding them and nowhere else, so one linked here names files that
       # are not there. The closure reaches the compiler, and a
       # version-named install keeps its database under a directory the
       # path filter matches.
       #
       # `-f`, since a package reachable by more than one path in the closure
       # offers the same registration more than once.
       libdir=$(${ghc}/bin/${prefix}ghc --print-libdir)

       for pkg in $(cat ${closure}/store-paths); do
         if [ -d "$pkg/lib" ]; then
           for conf in $(find "$pkg/lib" -path "*/${prefix}ghc-*/package.conf.d/*.conf"); do
             if [ ! -e "$libdir/package.conf.d/$(basename "$conf")" ]; then
               ln -sf "$conf" "$db/"
             fi
           done
         fi
       done

       ${ghc}/bin/${prefix}ghc-pkg --package-db="$db" recache

       # A database naming an absent unit id fails here, rather than in
       # whichever cabal run reaches it first and reports it as a package
       # it cannot resolve.
       ${ghc}/bin/${prefix}ghc-pkg --package-db="$db" check

       for exe in ${ghc}/bin/*; do
         name=$(basename "$exe")
         flags=""
         case "$name" in
       ${flagCases}
         esac
         if [ -n "$flags" ]; then
           rm -f "$out/bin/$name"
           makeWrapper "$exe" "$out/bin/$name" \
             --add-flags "''${flags//@db@/$db}"
         fi
       done
     '';
   }

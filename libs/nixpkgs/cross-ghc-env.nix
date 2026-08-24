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
# Everything else about that design is right and is kept. In particular the
# database stays where the compiler has it, relative to the compiler's root.
# A bindist registers its own libraries at paths under `${pkgroot}`, the
# parent of `package.conf.d`, and a database built anywhere else sends every
# one of them outside the store path. Only the way the position is found
# changes, from computing it to asking the compiler for it.
#
# Example:
#
#   import ./cross-ghc-env.nix { inherit pkgs lib; } {
#     ghc = <wasm32-wasi-ghc-9.12, libdir lib, targetPrefix "wasm32-wasi-">;
#     packages = [ <splitmix> ];
#   }
#   => <derivation wasm32-wasi-ghc-with-packages> holding
#
#        bin/wasm32-wasi-ghc      # -B <out>/lib
#        bin/wasm32-wasi-ghc-pkg  # --global-package-db=<out>/lib/package.conf.d
#        lib/                     # the compiler's, linked entry by entry
#        lib/package.conf.d/base-4.21.3.0-....conf       # the compiler's own
#        lib/package.conf.d/splitmix-0.1.3.2-....conf    # the package given
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

    # The executables that have to be told where the database went, and how each
    # spells it. Named rather than probed, since the case arms are written
    # before the compiler's `bin` can be listed. Every other tool there is
    # linked through untouched: one that reads no database gains nothing from a
    # wrapper.
    databaseReaders =
      [ { name = "${prefix}ghc-pkg"; flags = "--global-package-db=@libdir@/package.conf.d"; } ]
      ++ map (name: { inherit name; flags = "-B@libdir@"; })
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
     paths = [ ghc ] ++ packages;
     nativeBuildInputs = [ pkgs.makeWrapper ];
     passthru = { inherit (ghc) targetPrefix; }
       // lib.optionalAttrs (ghc ? version) { inherit (ghc) version; };
     postBuild = ''
       # The libdir is asked for rather than assumed. A version-named install
       # keeps it under lib/<prefix>ghc-<version>/lib, a relocatable bindist
       # directly under lib. `rel` is the same place inside the join.
       libdir=$(${ghc}/bin/${prefix}ghc --print-libdir)
       rel=''${libdir#${ghc}/}

       # The join linked the whole directory, since only the compiler carries
       # one at this path. Replace it with a real one holding the compiler's
       # registrations and the packages', each found where its own layout keeps
       # it.
       rm -rf "$out/$rel/package.conf.d"
       mkdir -p "$out/$rel/package.conf.d"

       for conf in "$libdir"/package.conf.d/*.conf; do
         ln -s "$conf" "$out/$rel/package.conf.d/"
       done

       # `-f`, since a package reachable by more than one path in the selection
       # offers the same registration more than once.
       for pkg in ${lib.escapeShellArgs (map toString packages)}; do
         if [ -d "$pkg/lib" ]; then
           find "$pkg/lib" -name '*.conf' -path '*/package.conf.d/*' \
             -exec ln -sf {} "$out/$rel/package.conf.d/" \;
         fi
       done

       ${ghc}/bin/${prefix}ghc-pkg --global-package-db="$out/$rel/package.conf.d" recache

       for exe in ${ghc}/bin/*; do
         name=$(basename "$exe")
         flags=""
         case "$name" in
       ${flagCases}
         esac
         if [ -n "$flags" ]; then
           rm -f "$out/bin/$name"
           makeWrapper "$exe" "$out/bin/$name" \
             --add-flags "''${flags//@libdir@/$out/$rel}"
         fi
       done
     '';
   }

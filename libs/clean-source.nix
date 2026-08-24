# Filter a source tree through the .gitignore files it carries, so build
# artifacts never reach the nix store. Without this, a project whose `src`
# is `./.` copies its own dist-newstyle into every derivation that names
# the source, and each build changes the hash of them all.
#
# A `src` that is already a derivation or a store path is returned
# untouched. There is nothing left to strip.
#
# Patterns are read with the tree root as their base:
# - A pattern that contains a slash ("backend/data/*") matches relative to
#   the root only.
# - A bare pattern ("dist-newstyle") matches at any depth.
# Nested .gitignore files can be read through `ignoreFiles`, but their
# anchored patterns are reinterpreted against the root. Where that matters,
# pass the bare patterns through `patterns` instead.
#
# Example:
#
#   import ./clean-source.nix { inherit pkgs; } { src = ./.; patterns = "dist-js"; }
#   => <a store copy of ./. without .git, the gitignored files and dist-js>
#
#   import ./clean-source.nix { inherit pkgs; } { src = <derivation or store path>; }
#   => the src, untouched
{ pkgs }:

{ src
  # Store name for the filtered copy. Defaults to the directory's own name.
, name ? null
  # Ignore files to read, relative to the tree root.
, ignoreFiles ? [ "/.gitignore" ]
  # Extra gitignore-syntax patterns, applied on top of the files above.
, patterns ? ""
}:

let inherit (pkgs) lib;

    readIfPresent = f:
      let p = src + f;
      in if builtins.pathExists p then builtins.readFile p else "";

    # .git is never listed in a .gitignore and must never be copied.
    ignores = lib.concatStringsSep "\n"
      ([ ".git" patterns ] ++ map readIfPresent ignoreFiles);

    # A path that already points into the store (a flake's own source, an
    # unpacked thunk) was filtered by whatever produced it. A copy under a
    # new name would only duplicate it.
    inStore = lib.hasPrefix builtins.storeDir (toString src);

in if !(builtins.isPath src) || inStore
   then src
   else builtins.path {
     name = lib.strings.sanitizeDerivationName
       (if name != null then name else baseNameOf src);
     path = src;
     filter = pkgs.nix-gitignore.gitignoreFilter ignores src;
   }

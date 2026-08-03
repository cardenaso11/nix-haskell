# The project's cabal.project, as seen by the nixpkgs driver.
#
# All parsing is haskell.nix's (lib/cabal-project-parser.nix, passed in as
# `parser`), combined with this repo's `import:` inlining (libs/cabal.nix).
# The `packages:` field is deliberately not interpreted: haskell.nix has no
# nix parser for it either (real cabal reads it inside the plan derivation),
# and this driver follows the same structure. Local packages come from the
# root of the source (haskell.nix's own `packages: ./*.cabal` default), from
# an explicit `nixpkgs.options.packages` map, or from the cabal plan when
# `nixpkgs.options.use-plan` is set.
#
# Example:
#
#   discover { src = ./hello; }
#   => { hello = { subdir = "."; src = ./hello; }; }
#
#   discover { src = ./monorepo; explicit = { frontend.subdir = "frontend"; }; }
#   => { frontend = { subdir = "frontend"; src = ./monorepo/frontend; }; }
#
#   sourceRepoStanzas ./project        # stanzas of its cabal.project
#   => [ { url = "https://github.com/reflex-frp/reflex-dom";
#          ref = "master"; sha256 = null; subdirs = [ "reflex-dom" ]; } ]
{ pkgs, parser }:

with pkgs.lib;

let inline-cabal-project = (import ../cabal.nix { inherit pkgs; }).inline-cabal-project;

    # The name of the cabal package in `dir`, or null when there is none.
    # Cabal requires the .cabal file to be named after the package, so the
    # filename is authoritative; hpack projects carry the name in
    # package.yaml.
    packageNameIn = dir:
      let entries = builtins.readDir dir;
          cabals = filter (hasSuffix ".cabal")
            (attrNames (filterAttrs (_: t: t == "regular" || t == "symlink") entries));
      in if length cabals > 1
         then throw "nix-haskell (nixpkgs driver): ${toString dir} contains more than one .cabal file"
         else if cabals != []
         then removeSuffix ".cabal" (head cabals)
         else if entries ? "package.yaml"
         then
           let matches = concatMap
                 (l: let m = builtins.match "name[[:space:]]*:[[:space:]]*\"?([^\"]+)\"?[[:space:]]*" l;
                     in if m == null then [] else [ (head m) ])
                 (splitString "\n" (builtins.readFile (dir + "/package.yaml")));
           in if matches == []
              then throw "nix-haskell (nixpkgs driver): no name field found in ${toString dir}/package.yaml"
              else head matches
         else null;

    # source-repository-package stanzas of the project file (with `import:`
    # lines inlined): [ { url; ref or rev; sha256; subdirs; } ]
    sourceRepoStanzas = src:
      if builtins.pathExists (src + "/cabal.project")
      then concatMap (b: optional (b ? sourceRepo) b.sourceRepo)
             (parser.parseSourceRepositoryPackages "cabal.project" null {}
               (inline-cabal-project src "cabal.project")).sourceRepos
      else [];

    # Local packages: { <package-name> = { subdir; src; }; }. An explicit map
    # (keyed by package name) takes precedence; otherwise the package at the
    # root of the source is the project.
    discover = { src, explicit ? null }:
      let dirAt = d: if d == "." then src else src + "/${d}";
          rootPackage =
            let name = packageNameIn src;
            in if name == null
               then throw "nix-haskell (nixpkgs driver): no .cabal file or package.yaml at the root of the project source; for a multi-package project set nixpkgs.options.packages or nixpkgs.options.use-plan"
               else { ${name} = { subdir = "."; src = src; }; };
      in if explicit != null
         then mapAttrs (_: p: { inherit (p) subdir; src = dirAt p.subdir; }) explicit
         else rootPackage;

in {
  inherit packageNameIn discover sourceRepoStanzas;
}

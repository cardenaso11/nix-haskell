# The source a `source-repository-package` stanza resolves to. The order:
#
# 1. `inputMap."<url>/<rev>"` (rev falls back to the stanza's ref)
# 2. `inputMap.<url>`
# 3. `pkgs.fetchgit`, when the stanza carries a sha256 (from a `--sha256`
#    comment or `sha256map`, applied by the parser)
# 4. `builtins.fetchGit`
#
# Example:
#
#   fetch = import ./fetch-stanza-source.nix { inherit lib; };
#
#   fetch {
#     stanza = { url = "https://github.com/reflex-frp/reflex-dom"; ref = "master"; sha256 = null; subdirs = [ "reflex-dom" ]; };
#     inputMap = { "https://github.com/reflex-frp/reflex-dom/master" = ./deps/reflex-dom; };
#     inherit pkgs;
#   }
#   => ./deps/reflex-dom
#
#   fetch {
#     stanza = { url = "https://github.com/reflex-frp/reflex-dom"; ref = "master"; sha256 = null; subdirs = [ "reflex-dom" ]; };
#     inputMap = {};
#     inherit pkgs;
#   }
#   => builtins.fetchGit { url = "https://github.com/reflex-frp/reflex-dom"; ref = "master"; }
{ lib }:

{ stanza, inputMap, pkgs }:

let url = builtins.unsafeDiscardStringContext stanza.url;

    rev = builtins.unsafeDiscardStringContext (stanza.rev or stanza.ref or "");

    byHash = pkgs.fetchgit { url = stanza.url; rev = stanza.rev or stanza.ref; inherit (stanza) sha256; };

    byGit = builtins.fetchGit
      ({ url = stanza.url; }
       // lib.optionalAttrs (stanza ? rev) { inherit (stanza) rev; }
       // lib.optionalAttrs (stanza ? ref) { inherit (stanza) ref; });

    fetched =
      if (stanza.sha256 or null) != null
      then byHash
      else byGit;

in inputMap."${url}/${rev}" or (inputMap.${url} or fetched)

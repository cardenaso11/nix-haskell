# The `shell.packages` selection a driver offers: the project's own
# `shell.packages` function when it gave one, else every local package
# that is not a source-repository-package.
#
# Example:
#
#   import ./shell-packages-selection.nix {
#     packages = null;
#     source-repository-packages = { dep-a = ./deps/dep-a; };
#   } { hello = { isLocal = true; identifier.name = "hello"; };
#       dep-a = { isLocal = true; identifier.name = "dep-a"; };
#     }
#   => [ { isLocal = true; identifier.name = "hello"; } ]
{ packages, source-repository-packages }:

if packages != null
then packages
else ps: builtins.filter
  (p: (p.isLocal or false) && !(source-repository-packages ? ${p.identifier.name or ""}))
  (builtins.attrValues ps)

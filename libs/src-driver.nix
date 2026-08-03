# Copy `src` with lines appended to its cabal.project (the file is created
# when the source has none).
#
# Example:
#
#   import ./src-driver.nix {
#     inherit pkgs;
#     src = ./hello;
#     extraCabalProject = [ "allow-newer: all" ];
#   }
#   => <a copy of ./hello whose cabal.project ends with "allow-newer: all">
{ src,
  pkgs,
  extraCabalProject
}:

let extraCabal = map (a: ''
      printf '%s\n' ${pkgs.lib.escapeShellArg a} >> $out/cabal.project
    '') extraCabalProject;

in pkgs.runCommand "modify-project" {} (
  ''
    cp -r ${src} $out
    chmod +w $out
    if [ -f $out/cabal.project ]; then
      chmod +w $out/cabal.project
    fi
  '' + builtins.concatStringsSep "\n" extraCabal
)

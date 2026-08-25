# The project text the driver reads source-repository-package stanzas
# from, in this order:
#
# 1. the project file, or `cabalProject`, which replaces it
# 2. cabal.project.local
# 3. the extraCabalProject lines
#
# Example:
#
#   project-text = import ./project-text.nix { inherit lib; };
#
#   project-text {
#     projectFile = "packages: .";
#     cabalProject = null;
#     cabalProjectLocal = "tests: true";
#     extraCabalProject = [ "allow-newer: aeson:*" ];
#   }
#   => "packages: .\ntests: true\nallow-newer: aeson:*"
#
#   project-text { projectFile = null; cabalProject = null; cabalProjectLocal = null; extraCabalProject = []; }
#   => ""
{ lib }:

{ projectFile, cabalProject, cabalProjectLocal, extraCabalProject }:

let base =
      if cabalProject != null
      then cabalProject
      else projectFile;

in lib.concatStringsSep "\n" (
     lib.optional (base != null) base
     ++ lib.optional (cabalProjectLocal != null) cabalProjectLocal
     ++ extraCabalProject)

# A linked `.jsexe` directory copied through with its `all.js` replaced by what
# closure-compiler makes of it. The rest of the directory is left alone, so
# whatever loads the program keeps finding what it expects beside it.
#
# The directory's own `all.externs.js`, which the linker writes next to the
# program, is always passed: under ADVANCED the compiler renames everything it
# is not told the runtime knows by name.
#
# Example:
#
#   import ./run.nix { inherit pkgs lib; } {
#     jsexe = "${frontend}/bin/frontend.jsexe";
#     enable = true;
#     level = "ADVANCED";
#     externs = [];
#     extraFlags = [ "--language_in UNSTABLE" "--warning_level QUIET" "--isolation_mode IIFE"
#                    "--assume_function_wrapper" "--emit_use_strict"
#                    "--jscomp_off=undefinedVars" ];
#   }
#   => <derivation frontend.jsexe-optimized>     # all.js compiled down;
#                                                # all.externs.js, rts.js,
#                                                # index.html and the rest as
#                                                # they were
#
#   import ./run.nix { inherit pkgs lib; } {
#     jsexe = "${frontend}/bin/frontend.jsexe";
#     enable = false;
#     level = "ADVANCED";
#     externs = [];
#     extraFlags = [];
#   }
#   => <derivation frontend.jsexe-unoptimized>   # the directory handed in, copied
#                                                # through, so a caller installs the
#                                                # same layout either way
{ pkgs, lib }:

{ jsexe, enable, level, externs, extraFlags }:

let # A whole derivation names itself; a directory inside one is named by its own
    # last component, rather than by the store path it sits in.
    name = if lib.isDerivation jsexe then jsexe.name else baseNameOf jsexe;

    flags = lib.concatStringsSep " " (
      [ "--compilation_level ${level}" ]
      ++ map (extern: "--externs ${extern}") externs
      ++ extraFlags);

in if ! enable
   then pkgs.runCommand "${name}-unoptimized" {} ''
     cp -r ${jsexe} $out
   ''
   else pkgs.runCommand "${name}-optimized" {
     nativeBuildInputs = [ pkgs.closurecompiler ];
   } ''
     cp -r ${jsexe} $out
     chmod -R u+w $out
     closure-compiler --externs $out/all.externs.js ${flags} \
       --js $out/all.js \
       --js_output_file $out/all.js.opt
     mv -f $out/all.js.opt $out/all.js
   ''

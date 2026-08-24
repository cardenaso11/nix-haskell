# The settings closure-compiler takes, as the option declarations for one layer
# of the tree they can be stated on. The fields are the tool's own flags, so a
# level is checked against the vocabulary that reads it rather than against
# another tool's. `inherits` decides the kind of layer;
# `../bundle-optimizer-field.nix` spells out what it does.
#
# Example:
#
#   import ./options.nix { inherit lib; }
#   => { enable     = <bool, default true>;
#        level      = <enum [ "BUNDLE" "WHITESPACE_ONLY" "SIMPLE" "TRANSPILE_ONLY"
#                       "ADVANCED" ], default "ADVANCED">;
#        externs    = <listOf path, default []>;
#        extraFlags = <listOf str, default [ "--language_in UNSTABLE"
#                       "--warning_level QUIET" "--isolation_mode IIFE"
#                       "--assume_function_wrapper" "--emit_use_strict"
#                       "--jscomp_off=undefinedVars" ]>;
#      }
#
#   import ./options.nix {
#     inherit lib;
#     inherits = "the setting for this package whatever the target";
#   }
#   => the same four fields, every one `nullOr` of its type and defaulting to
#      `null`, its description saying what `null` leaves it to
{ lib, inherits ? null }:

let field = import ../bundle-optimizer-field.nix { inherit lib inherits; };

in {

  enable = field {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether `js-optimize` runs closure-compiler at all. When false it
      copies the jsexe through unchanged.
    '';
  };

  level = field {
    type = lib.types.enum [ "BUNDLE" "WHITESPACE_ONLY" "SIMPLE" "TRANSPILE_ONLY" "ADVANCED" ];
    default = "ADVANCED";
    description = ''
      The `--compilation_level` closure-compiler runs at.
    '';
    example = "SIMPLE";
  };

  externs = field {
    type = lib.types.listOf lib.types.path;
    default = [];
    description = ''
      Files passed as `--externs`, declaring what the program reaches by a
      name the compiler must not rename. The jsexe's own `all.externs.js` is
      always passed ahead of these, since ADVANCED renames everything it is
      not told the runtime knows by name.
    '';
  };

  extraFlags = field {
    type = lib.types.listOf lib.types.str;
    default = [
      "--language_in UNSTABLE"
      "--warning_level QUIET"
      "--isolation_mode IIFE"
      "--assume_function_wrapper"
      "--emit_use_strict"
      "--jscomp_off=undefinedVars"
    ];
    description = ''
      Flags appended after the level and the externs, so one of these decides
      what they would have. One flag per element, its value in the same
      string, since the elements are joined into one command line.

      The default accepts whatever syntax the linker emitted, keeps the
      compiler quiet, wraps the program in a function expression it may
      assume nothing escapes from, asks for strict mode, and stops it
      complaining about the names the runtime defines elsewhere.
    '';
  };

}

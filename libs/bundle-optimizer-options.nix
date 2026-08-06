# The settings each bundle optimizer takes, as the option declarations for
# one layer of the tree they can be stated on. `inherits` describes the layer
# beneath: a layer that has one is nullable throughout, where `null` states
# nothing and leaves the field to that layer, and the one layer without it
# carries the values every field falls back to.
#
# The fields are the tools' own flags, so a level is checked against the
# vocabulary of the tool that reads it rather than against the other's.
#
# Example:
#
#   import ./bundle-optimizer-options.nix { inherit lib; }
#   => { wasm-opt = { enable     = <bool, default true>;
#                     level      = <enum [ "0" "1" "2" "3" "4" "s" "z" ], default "2">;
#                     extraFlags = <listOf str, default [ "-ol 2" "-s 1"
#                                    "--low-memory-unused" "--strip-dwarf" "--converge" ]>;
#                   };
#        closure  = { enable     = <bool, default true>;
#                     level      = <enum [ "BUNDLE" "WHITESPACE_ONLY" "SIMPLE"
#                                    "TRANSPILE_ONLY" "ADVANCED" ], default "ADVANCED">;
#                     externs    = <listOf path, default []>;
#                     extraFlags = <listOf str, default [ "--language_in UNSTABLE"
#                                    "--warning_level QUIET" "--isolation_mode IIFE"
#                                    "--assume_function_wrapper" "--emit_use_strict"
#                                    "--jscomp_off=undefinedVars" ]>;
#                   };
#      }
#
#   import ./bundle-optimizer-options.nix {
#     inherit lib;
#     inherits = "the setting for this package whatever the target";
#   }
#   => the same two field sets, every field `nullOr` of its type and defaulting
#      to `null`, its description saying what `null` leaves it to
{ lib, inherits ? null }:

let stated = inherits == null;

    leftTo = lib.optionalString (! stated) ''

      `null` states nothing, leaving the field to ${inherits}.
    '';

    field = { type, default, description, example ? null }:
      lib.mkOption ({
        type = if stated then type else lib.types.nullOr type;
        default = if stated then default else null;
        description = description + leftTo;
      } // lib.optionalAttrs (example != null) { inherit example; });

in {

  wasm-opt = {

    enable = field {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether `wasm-optimize` runs wasm-opt and the strip that follows it at
        all. When false it copies its input through, so what a caller installs
        sits in the same place either way.
      '';
    };

    level = field {
      type = lib.types.enum [ "0" "1" "2" "3" "4" "s" "z" ];
      default = "2";
      description = ''
        The `-O` level wasm-opt runs at.
      '';
      example = "z";
    };

    extraFlags = field {
      type = lib.types.listOf lib.types.str;
      default = [ "-ol 2" "-s 1" "--low-memory-unused" "--strip-dwarf" "--converge" ];
      description = ''
        Flags appended after `-all -O<level>`, so one of these decides what the
        level would have. One flag per element, its value in the same string,
        since the elements are joined into one command line.

        The default asks for the optimize level of `-O2` at the shrink level of
        `-O1`, drops the memory a module never reads, discards debug
        information, and repeats the passes until they stop finding anything.
      '';
    };

  };

  closure = {

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

  };

}

# The settings wasm-opt takes, as the option declarations for one layer of the
# tree they can be stated on. The fields are the tool's own flags, so a level is
# checked against the vocabulary that reads it rather than against another
# tool's. `inherits` decides the kind of layer; `../bundle-optimizer-field.nix`
# spells out what it does.
#
# Example:
#
#   import ./options.nix { inherit lib; }
#   => { enable     = <bool, default true>;
#        level      = <enum [ "0" "1" "2" "3" "4" "s" "z" ], default "2">;
#        extraFlags = <listOf str, default [ "-ol 2" "-s 1" "--low-memory-unused"
#                       "--strip-dwarf" "--converge" ]>;
#      }
#
#   import ./options.nix {
#     inherit lib;
#     inherits = "the setting for this package whatever the target";
#   }
#   => the same three fields, every one `nullOr` of its type and defaulting to
#      `null`, its description saying what `null` leaves it to
{ lib, inherits ? null }:

let field = import ../bundle-optimizer-field.nix { inherit lib inherits; };

in {

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

}

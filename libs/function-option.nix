# An option whose value is a function rather than a setting. The manual carries
# both kinds in one list, and a type alone is easy to read past, so the
# description says which it is before it says anything else.
#
# `result` is what the function returns, defaulting to a package. Everything
# else is passed to `mkOption` as given, so `default`, `defaultText` and an
# `example` all still work.
#
# Example:
#
#   import ./function-option.nix { inherit lib; } {
#     default = platform: <the compiler for that platform>;
#     defaultText = lib.literalMD "```\nplatform: ...\n```";
#     description = ''
#       The compiler this driver builds a cross target with.
#     '';
#   }
#   => <option, type "function that evaluates to a(n) package", the default and
#      defaultText as given, description
#
#      "**A function, not a setting.** A project calls it and uses what comes
#       back. Assign it only to replace what the call does.
#
#       The compiler this driver builds a cross target with.">
{ lib }:

let # A trailing blank line, so what follows starts its own paragraph rather
    # than running on from the label.
    marker = ''
      **A function, not a setting.** A project calls it and uses what comes
      back. Assign it only to replace what the call does.

    '';

in args@{ result ? lib.types.package, description, ... }:

   lib.mkOption (removeAttrs args [ "result" ] // {
     type = lib.types.functionTo result;
     description = marker + description;
   })

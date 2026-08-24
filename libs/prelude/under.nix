# Keys a value under each of the given names:
# - `null` returns the value unchanged.
# - A list of names gives an attrset holding the value under every name.
#
# Example:
#
#   under = import ./under.nix;
#
#   under null "x"
#   => "x"
#
#   under [ "a" "b" ] "x"
#   => { a = "x"; b = "x"; }
#
#   under [] "x"
#   => { }
names:

value:

if names == null
then value
else builtins.listToAttrs (map (name: { inherit name value; }) names)

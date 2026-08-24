# Classifies an option type for descent into sub-options:
# - `isSubmodule`: the type is a `submodule`.
# - `isAttrsOfSubmodule`: the type is an `attrsOf` or `lazyAttrsOf` of
#   `submodule`.
# - `elemType`: the element type of a nesting type, `null` elsewhere.
#
# Example:
#
#   submodule-type = import ./submodule-type.nix;
#
#   submodule-type (lib.types.submodule {})
#   => { isSubmodule = true; isAttrsOfSubmodule = false; elemType = null; }
#
#   submodule-type (lib.types.attrsOf (lib.types.submodule {}))
#   => { isSubmodule = false; isAttrsOfSubmodule = true;
#        elemType = the submodule type; }
#
#   submodule-type lib.types.str
#   => { isSubmodule = false; isAttrsOfSubmodule = false; elemType = null; }
type:

let elemType = type.nestedTypes.elemType or null;

in {
  inherit elemType;

  isSubmodule = type.name == "submodule";

  isAttrsOfSubmodule =
    (type.name == "attrsOf" || type.name == "lazyAttrsOf")
    && (elemType.name or "") == "submodule";
}

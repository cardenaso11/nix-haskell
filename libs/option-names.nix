# Names of the user-settable options in an evaluated options tree. Internal,
# read-only and hidden options are excluded, as are the namespaces listed in
# `excludes`. Sub-options of submodule-typed options are named one level
# deep, and a plain namespace of options counts as a single name.
#
# Example:
#
#   import ./option-names.nix {
#     inherit lib;
#     excludes = [ "haskell-nix" ];
#     options = {            # an evaluated `options` tree, containing e.g.
#       src = ...;           #   an ordinary option
#       src-cleaned = ...;   #   a readOnly option
#       shell = ...;         #   a submodule-typed option
#       packages = ...;      #   an attrsOf-submodule option
#       optimizations = ...; #   a plain namespace of options
#       haskell-nix = ...;   #   an excluded namespace
#     };
#   }
#   => [ "optimizations" "packages.*.flags" ... "packages.*.src"
#        "shell.buildInputs" ... "shell.withHoogle" "src" ]

{ lib, options, excludes ? [] }:

with lib;

let isVisible = option':
      let defaults = {
            visible = true;
            internal = false;
            readOnly = false;
          };
          option = defaults // option';
      in all id
        [ (option.visible != false)
          (!option.internal)
          (!option.readOnly)
        ];

    subNames = prefix: opts:
      let visibleOptions = filterAttrs (n: o: n != "_module" && isOption o && isVisible o) opts;
          visibleOptionNames = attrNames visibleOptions;
      in map (n: prefix + n) visibleOptionNames;

    expand = name: option:
      let type = option.type;
          elemType = type.nestedTypes.elemType or null;

          isSubmodule = type.name == "submodule";
          isAttrsOfSubmodule =
               (type.name == "attrsOf" || type.name == "lazyAttrsOf")
            && (elemType.name or "") == "submodule";

      in  if isSubmodule
            then subNames "${name}." (type.getSubOptions [])
          else if isAttrsOfSubmodule
            then subNames "${name}.*." (elemType.getSubOptions [])
          else [ name ];

    includedOptions = filterAttrs
      (name: _: name != "_module" && !(elem name excludes))
      options;

    optionNames = name: option:
      if isOption option
      then optionals (isVisible option) (expand name option)
      else [ name ];

in sort lessThan (concatLists (mapAttrsToList optionNames includedOptions))

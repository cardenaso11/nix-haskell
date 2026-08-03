# The user-settable common options: what every driver's translation table
# must cover. Driver namespaces, internal and read-only options are excluded;
# submodule-typed options (shell) and attrsOf-submodule options (packages)
# are expanded one level, so their sub-options are part of the contract.
{ lib, options, driverNamespaces }:

with lib;

let visible = o:
      (o.visible or true) != false && !(o.internal or false) && !(o.readOnly or false);

    isOption = v: (v._type or "") == "option";

    subNames = prefix: opts:
      concatLists (mapAttrsToList
        (n: o: optional (n != "_module" && isOption o && visible o) "${prefix}${n}")
        opts);

    expand = name: o:
      let t = o.type;
      in if t.name == "submodule"
         then subNames "${name}." (t.getSubOptions [])
         else if (t.name == "attrsOf" || t.name == "lazyAttrsOf")
                 && (t.nestedTypes.elemType.name or "") == "submodule"
         then subNames "${name}.*." (t.nestedTypes.elemType.getSubOptions [])
         else [ name ];

in sort lessThan (concatLists (mapAttrsToList
     (name: v:
       if name == "_module" || elem name driverNamespaces then []
       else if isOption v
       then optionals (visible v) (expand name v)
       else [ name ])
     options))

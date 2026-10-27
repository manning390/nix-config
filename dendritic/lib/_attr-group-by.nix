/*
attrGroupBy (v: v.type) { a = { type = "x"; }; b = { type = "y"; }; c = { type = "x"; }; }
=> { x = { a = { type = "x"; }; c = { type = "x"; }; };
     y = { b = { type = "y"; }; }; }
*/
lib: f: attrs:
attrs
|> lib.mapAttrsToList (name: value: {inherit name value;})
|> lib.groupBy (x: f x.value)
|> lib.mapAttrs (_: lib.listToAttrs)

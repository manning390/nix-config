lib: f: attrs:
attrs
|> lib.mapAttrsToList (name: value: {inherit name value;})
|> lib.groupBy (x: f x.value)
|> lib.mapAttrs (_: lib.listToAttrs)

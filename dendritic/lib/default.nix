{inputs, ...}: {
  # Available as:
  # output.lib
  # inputs.self.lib
  # self.lib
  # exposed as lib in specialArgs through hosts/default
  # Currently no aspect to include, so not present in base/default
  flake.lib = inputs.nixpkgs.lib.extend (final: prev: let
    lib = final;
  in {
    custom = {
      # Root of this config, same level as flake.nix
      relativeToRoot = path: lib.path.append ../../. path;
      /*
      attrGroupBy (v: v.type) { a = { type = "x"; }; b = { type = "y"; }; c = { type = "x"; }; }
      => { x = { a = { type = "x"; }; c = { type = "x"; }; };
           y = { b = { type = "y"; }; }; }
      */
      attrGroupBy = f: attrs:
        attrs
        |> lib.mapAttrsToList (name: value: {inherit name value;})
        |> lib.groupBy (x: f x.value)
        |> lib.mapAttrs (
          key: list:
            list
            |> map (x: {
              inherit (x) name;
              value = x.value;
            })
            |> lib.listToAttrs
        );
    };
  });
}

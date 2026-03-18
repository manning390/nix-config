{inputs, ...}: {
  # Available as:
  # output.lib
  # input.self.lib
  # self.lib
  # exposed as lib in specialArgs through hosts/default
  # Currently no aspect to include, so not present in base/default
  flake.lib = inputs.nixpkgs.lib.extend (final: prev: {
    custom = import ../../lib { lib = final; };
  });
}

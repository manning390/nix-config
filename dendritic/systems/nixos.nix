{
  inputs,
  lib,
  ...
}: {
  systems = ["x86_64-linux"]; # This is a flake-part setting and therefore imported everywhere, here for semantic reasons

  flake-file.inputs.determinate.url = lib.mkDefault "https://flakehub.com/f/DeterminateSystems/determinate/*";

  flake.aspects.nixos = {
    nixos = {
      imports = [inputs.determinate.nixosModules.default];
    };
    homeManager = {};
  };
}

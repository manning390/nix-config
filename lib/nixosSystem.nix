{
  lib,
  nixpkgs,
  home-manager,
  system,
  specialArgs,
  nixos-modules,
  home-modules ? [],
}: let
  inherit (specialArgs) username;
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      nixos-modules
      ++ (
      lib.optionals ((lib.lists.length home-modules) > 0)
      [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users."${username}".imports = home-modules;
        }
      ]
    );
  }

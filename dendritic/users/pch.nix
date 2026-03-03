let
  username = "pch"; # This is where we define this user, has to be hard coded
in {
  flake.aspects = {aspects, ...}: {
    "user-${username}" = {
      includes = with aspects; [
        fish
        kitty
        wiki
        zoxide
      ];

      nixos = {
        users.users.${username} = {
          isNormalUser = true;
          extraGroups = ["wheel" "networkmanager" "audio" "docker" "video"];
        };
      };

      homeManager = {
        imports = [
          ../../home/core/nvim # Need to convert nvim to dendritic, oh boy...
        ];

      };
    };
  };
}

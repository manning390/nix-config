let
  username = "pch"; # This is where we define this user, has to be hard coded
in {
  flake.aspects = {aspects, ...}: {
    "user-${username}" = {
      includes = with aspects; [
        fish
        kitty
        nvim
        wiki
        yazi
        zoxide
        zsh
      ];

      nixos = {lib, ...}: {
        users.users.${username} = {
          isNormalUser = true;
          extraGroups = ["wheel" "networkmanager" "audio" "docker" "video"];
        };
        local.kitty.enable = lib.mkDefault true;
      };

      homeManager = {};
    };
  };
}

let
  username = "ruby";
in {
  flake.aspects = {aspects, ...}: {
    "user-${username}" = {
      includes = with aspects; [
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
          openssh.authorizedKeys.keys = [];
        };
        local.kitty.enable = lib.mkDefault true;
      };

      homeManager = {};
    };
  };
}

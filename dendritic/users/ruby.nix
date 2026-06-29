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

      nixos = {
        users.users.${username} = {
          isNormalUser = true;
          extraGroups = ["wheel" "networkmanager" "audio" "docker" "video"];
          openssh.authorizedKeys.keys = [];
        };
      };

      homeManager = {};
    };
  };
}

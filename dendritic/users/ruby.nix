let
  username = "ruby";
in {
  flake.aspects = {aspects, ...}: {
    "user-${username}" = {
      includes = with aspects; [
        zsh
        kitty
        wiki
        zoxide
      ];

      nixos = {
        users.users.${username} = {
          isNormalUser = true;
          extraGroups = ["wheel" "networkmanager" "audio" "docker" "video"];
          openssh.authorizedKeys.keys = [];
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

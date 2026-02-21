let
  username = "pch"; # This is where we define this user, has to be hard coded
in {
  flake.aspects = {aspects, ...}: {
    ${username} = {
      includes = with aspects; [
        fish
        kitty
        wiki
        zoxide
      ];

      nixos = {
        users.users.${username} = {
          isNormalUser = true;
          extraGroups = ["wheel"];
        };
      };

      homeManager = {
        imports = [
          ../../home/core/nvim
          ../../home/core/git
        ];

        programs = {
          man.enable = true;
          bat = {
            enable = true;
            # configs wip
          };
          fd.enable = true; # says doesn't exist?
          btop.enable = true;
          jq.enable = true;
          aria2.enable = true;
        };
      };
    };
  };
}

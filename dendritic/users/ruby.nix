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

        local = {
          desktop.caelestia = {
            enable = true;
            showBattery = true;
            showBrightness = true;
          };
        };

        home.sessionVariables = {
          PATH = "$HOME/.local/bin:$PATH";
          DOTFILES = "$HOME/.dotfiles";
          NIXCONFIG = "$HOME/Code/nix/nix-config";
          COLEMAK = "1";
        };

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

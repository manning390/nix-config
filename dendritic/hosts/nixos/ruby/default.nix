{inputs, ...}: let
  hostname = "ruby";
  user = "ruby";
in {
  local.hosts.${hostname} = {
    type = "nixos";
    stateVersion = "24.05";
  };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      description = "Framework laptop with red border";
      includes = with aspects; [
        base
        (homeManager._.users user)
        desktop
        caelestia
        discord
      ];

      nixos = {
        local.identity.username = user;
        imports = [
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
          ./_hardware-configuration.nix
          ../../../../modules/shells.nix
        ];

        local = {
          colemak_dhm.enable = true;
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
          sops.enable = true;
        };

        environment.sessionVariables = {
          COLEMAK = "1";
        };
      };

      homeManager = {
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
        };
      };# Required for included homeManager modules to be imported
    };
  };
}

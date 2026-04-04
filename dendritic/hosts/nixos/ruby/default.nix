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
        hardware
        (hardware._.hosts hostname)
        (homeManager._.users user)
        desktop
        caelestia
        discord
        _1password
      ];

      nixos = {
        # Overwrite our default user identity
        local.identity.username = user;
        imports = [ inputs.nixos-hardware.nixosModules.framework-13-7040-amd ];

        # My defined configurations for modules
        local = {
          colemak_dhm.enable = true;
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
          # wireguard.enable = true;
          sops.enable = true;
          ssh = {
            enable = true;
            users."${user}" = {
              connectTo = ["pch@sentry" "pch@glaciem"];
              authorizedKeys = ["pch@sentry" "pch@mado"];
              extraHosts = {
                "github.com" = {
                  hostname = "github.com";
                  user = "git";
                  identityFile = "github";
                };
              };
            };
          };
        };

        environment.sessionVariables = {
          COLEMAK = "1";
        };
      };

      # Required for included homeManager modules to be imported
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
      };
    };
  };
}

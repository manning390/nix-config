{self, inputs,...}: let
  hostname = "sentry";
  user = "pch";
in {
  # Not activating yet...
  # local.hosts.${hostname} = {
  #   type = "nixos";
  #   stateVersion = "23.11";
  # };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      description = "Slim gray desktop war machine";

      includes = with aspects; [
        base
        hardware
        (hardware._.hosts hostname)
        (homeManager._.users user)
        caelestia
        desktop
        discord
        gaming
        godot
        _1password
        abidan-archive-backup
      ];

      nixos = {
        local = {
          hardware = {
            gpu.enable = true;

            # This will likely be changed in the future with different format
            monitors = {
            "HDMI-A-1" ="2560x1440@144,0x0,1"; # left
            "DP-1"     = "2560x1440@144,2560x0,1"; # center
            "HDMI-A-2" = "2560x1440@144,5120x0,1"; #right 
            };
          };
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
          sops.homeOnSeparatePartition = true;
          abidan-archive-backup.enable = true;
        };

        environment.sessionVariables = {
          COLEMAK = "1";
          NIXCONFIG = "/home/${user}/Code/nix/nix-config";
        };
      };

      # Required for included homeManager modules to be imported
      homeManager = {
        local = {
          desktop.caelestia = {
            enable = true;
            excludedScreens = ["HDMI-A-1" "HDMI-A-2"];
          };
        };
      };
    };
  };
}

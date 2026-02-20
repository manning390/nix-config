{config, pkgs, lib, ...}: let
  machineName = "glaciem";
  user = config.local.identity.username;
in {
  config.local.hosts.${machineName} = {
    type = "nixos";
    aspects = []; #lib.splitString "," "git,wiki";
    modules = [
      ../../../../modules/shells.nix
      ./_hardware-configuration.nix
      ./_disk-config.nix
      ./_impermanence.nix
      ./_impermanence.nix
      {
        networking = {
            hostName = machineName;
            hostId = "9dea9b66";
            networkmanager.enable = false;
            useDHCP = true;
        };

        users.user.${user} = {
          isNormalUser = true;
        };

        # My local configuration options
        local = {
          shells = {
            systemShell = "bash";
            userShell = "fish";
          };
          sops.enable = true;
        };

        environment.systemPackages = with pkgs; [
          pciutils
          glances
          hdparm
          hd-idle
          hddtemp
          cpufrequtils
          powertop
        ];

        environment.sessionVariables = {
          NIXCONFIG = "/home/${user}/Code/nix/nix-config";
        };
      }
    ];
    homeManagerModules = [];
    stateVersion = "25.05";
  };
}

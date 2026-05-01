{self, inputs,...}:let
  hostname = "glaciem";
  user = "pch";
in {
  local.hosts.${hostname} = {
    type = "nixos";
    stateVersion = "25.05";
  };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      description = "Homelab system white cube";

      includes = with aspects; [
        base
        (hardware._.hosts hostname)
        (homeManager._.users user)
        usbdrives
        hdd-monitor
        homelab
      ];

      nixos = {config, pkgs, lib, ...}: let
        nixCfgPath = "/home/${user}/nix-config";
      in {
        imports = [
          self.modules.nixos.impermanence-glaciem
          ./_disk-config.nix
          ./_homelab.nix
        ];

        # Experiment to check how frequently drives would spindown
        services.hdd-monitor = {
          enable = true;
          poolName = "hdd-pool";
          checkInterval = "5min";
        };

        local = {
          sops.generateKeys = false;
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
          ssh ={
            enable = true;
            users."${user}" = {
              authorizedKeys = ["pch@sentry" "pch@mado" "pch@glaciem" "ruby@ruby"];
              extraHosts = {
                "github.com" = {
                  hostname = "github.com";
                  user = "git";
                  identityFile = "github";
                };
              };
            };
          };
          git.server = {
            enable = true;
            authorizedKeys = config.users.users."${user}".openssh.authorizedKeys.keys;
          };
          nix.flakePath = nixCfgPath;
        };

        services.openssh = {
          enable = true;
          openFirewall = true;
          settings = {
            # Forbid root login through SSH.
            PermitRootLogin = "no";
          };
        };

        environment.systemPackages = with pkgs; [
          hdparm
          hd-idle
          hddtemp
          cpufrequtils
          powertop
        ];

        networking = {
          hostId = "9dea9b66";
          networkmanager.enable = false;
          useDHCP = true;
        };

        environment.sessionVariables = {
          NIXCONFIG = nixCfgPath;
        };
      };

      # Required for included homeManager modules to be imported
      homeManager = {};
    };
  };
}

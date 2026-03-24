{self, inputs,...}:let
  hostname = "glaciem";
  user = "pch";
  nixCfgPath = "/home/${user}/nix-config";
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
        (hardware hostname)
        (homeManager._.users user)
        usbdrives
      ];

      nixos = {config, pkgs, ...}: {
        imports = [
          inputs.disko.nixosModules.disko
          ./_disk-config.nix
          self.modules.nixos.impermanence-glaciem
          ./_homelab.nix
          ../../../../modules/homelab
        ];

        local = {
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
          ssh ={
            enable = true;
            users."${user}" = {
              authorizedKeys = ["pch@sentry" "pch@mado" "pch@glaciem"];
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

        # systemd.services.hd-idle = {
        #   description = "External HD spin down daemon";
        #   wantedBy = ["multi-user.target"];
        #   serviceConfig = {
        #     Type = "simple";
        #     ExecStart = let
        #       idleTime = toString 900;
        #       hardDriveParameter = lib.strings.concatMapStringSep " " (x: "-a ${x} ie ${idleTime}") hardDrives;
        #     in "${pkgs.hd-idle}/bin/hd-idle -i 0 ${hardDriveParameter}";
        #   };
        # };

        environment.sessionVariables = {
          NIXCONFIG = nixCfgPath;
        };
      };

      # Required for included homeManager modules to be imported
      homeManager = {};
    };
  };
}

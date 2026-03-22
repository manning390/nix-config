{config, ...}: let
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
      description = "Homelab system";
      includes = with aspects; [
        base
        (homeManager._.users user)
        usbdrives
      ];
      nixos = {pkgs,...}: {
        imports = [
          ./_hardware-configuration.nix
          ./_disk-config.nix
          ./_impermanence.nix
          ./_homelab.nix
          ../../../../modules/shells.nix
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
              authorizedKeys = ["pch@sentry" "pch@mado"];
              extraHosts = {
                "github.com" = {
                  hostName = "github.com";
                  user = "git";
                  identityFile = "github";
                };
              };
            };
          };
          git.server.enable = true;
          nix.flakePath = nixCfgPath;
        };

        users.users.${user}.openssh.authorizedKeys.keys = [];
        services.openssh = {
          enable = true;
          openFirewall = true;
          settings = {
            # Forbid root login through SSH.
            PermitRootLogin = "no";
          };
        };

        environment.systemPackages = with pkgs; [
          glances
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
      homeManager = {};
    };
  };
}

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  hostname = "glaciem";
  user = config.local.identity.username;
in {
  local.hosts.${hostname} = {
    type = "nixos";
    stateVersion = "25.05";
  };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      includes = with aspects; [
        base
        (homeManager._.users user)
      ];

      nixos = {config,...}: {
        imports = [
          ../../../../modules/common.nix
          ../../../../modules/shells.nix
          ../../../../modules/homelab
          ./_hardware-configuration.nix
          ./_disk-config.nix
          ./_impermanence.nix
          ./_homelab.nix
          inputs.nix-private.nixosModules.ssh-hosts
        ];

        local = {
          shells = {
            systemShell = "bash";
            userShell = "fish";
          };
          nix.flakePath = lib.mkForce "/home/${user}/nix-config";
          git.server = {
            enable = true;
            authorizedKeys = [];
          };
        };

        networking = {
          hostName = hostname;
          hostId = "9dea9b66";
          networkmanager.enable = false;
          useDHCP = true;
        };

        # Put these in aspects which require them
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

        # Glaciem User overrides
        sops.secrets."user_passwords/glaciem".neededForUsers = true;
        users.users.${user} = {
          # hashedPasswordFile = config.sops.secrets."user_passwords/glaciem".path;
          openssh.authorizedKeys.keys = [
            # (builtins.readFile ./keys/user_pch_glaciem_ed25519_key.pub)
            config.local.ssh.publicKeys."pch@glaciem.pub"
          ];
        };

        services.openssh = {
          enable = true;
          openFirewall = true;
          settings = {
            # Forbid root login through SSH.
            PermitRootLogin = "no";
          };
        };
      };

      homeManager = {};
    };
  };
}

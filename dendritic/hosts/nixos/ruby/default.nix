{
  self,
  inputs,
  ...
}: let
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
        laptop
        (hardware._.hosts hostname)
        (homeManager._.users user)
        desktop
        caelestia
        discord
        _1password
        homelab
      ];

      nixos = {config, ...}: {
        # Overwrite our default user identity
        local.identity.username = user;

        imports = [inputs.nixos-hardware.nixosModules.framework-13-7040-amd];

        # No swap/resume device is configured, so only suspend is supported.
        systemd.sleep.settings.Sleep = {
          AllowHibernation = false;
          AllowHybridSleep = false;
          AllowSuspendThenHibernate = false;
        };
        services.upower = {
          criticalPowerAction = "PowerOff";
          percentageAction = 3;
        };

        # My defined configurations for modules
        local = {
          colemak_dhm.enable = true;
          wm.hyprland.devices = [
            {
              name = "at-translated-set-2-keyboard";
              kb_layout = "colemak_dhm,us";
              kb_options = "caps:escape,grp:alt_shift_toggle";
              resolve_binds_by_sym = true;
            }
          ];
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
          wireguard.enable = true;
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
                "glaciem.git" = {
                  hostname = config.local.lan.hosts.glaciem;
                  user = "forgejo";
                  identityFile = "${user}@${hostname}";
                  extraOptions.Port = self.nixosConfigurations.glaciem.config.homelab.services.forgejo.sshPort;
                };
              };
            };
          };
        };

        homelab = {
          baseDomain = "glaciem.home";
          samba.client = {
            enable = true;
            mountOptions = builtins.concatStringsSep "," [
              "vers=3.1.1"
              "rw"
              "noperm"
              "uid=1000"
              "gid=100"
              "_netdev"
              "nofail"
              "x-systemd.automount"
              "x-systemd.idle-timeout=10min"
              "x-systemd.mount-timeout=10s"
            ];
          };
        };

        environment.sessionVariables.COLEMAK = "1";
      };

      # Required for included homeManager modules to be imported
      homeManager = {
        local = {
          desktop.caelestia = {
            enable = true;
            showBattery = true;
            showBrightness = true;
            writableSettings = true;
            idle.suspendAfter = 600;
          };
        };

        home.sessionVariables = {
          PATH = "$HOME/.local/bin:$PATH";
          DOTFILES = "$HOME/.dotfiles";
          NIXCONFIG = "$HOME/Code/nix/nix-config";
        };

        # Use the session menu's sleep slot for supported suspend-to-RAM.
        programs.caelestia.settings.session = {
          commands.hibernate = ["suspend"];
          icons.hibernate = "bedtime";
        };
      };
    };
  };
}

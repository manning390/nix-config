{self, ...}: {
  flake-file.inputs.caelestia-shell = {
    url = "github:caelestia-dots/shell";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  flake.aspects = {aspects, ...}: {
    caelestia = {
      description = "Desktop build with caelestia shell on hyprland.";
      includes = [aspects.hyprland];

      nixos = {
        config,
        lib,
        ...
      }: {
        imports = [self.modules.nixos.caelestia-options];

        config = lib.mkIf (!config.local.desktop.caelestia.allowSuspend) {
          systemd.sleep.settings.Sleep = {
            AllowSuspend = false;
            AllowHibernation = false;
            AllowHybridSleep = false;
            AllowSuspendThenHibernate = false;
          };
        };
      };

      homeManager = {
        config,
        lib,
        inputs,
        osConfig,
        pkgs,
        ...
      }: let
        cfg = config.local.desktop.caelestia;
        vpn = osConfig.local.desktop.caelestia.vpn;
      in {
        imports = [
          self.modules.homeManager.caelestia-options
          inputs.caelestia-shell.homeManagerModules.default
        ];

        config = lib.mkIf cfg.enable {
          assertions = [
            {
              assertion = cfg.idle.suspendAfter == null || osConfig.local.desktop.caelestia.allowSuspend;
              message = "Caelestia idle suspend requires local.desktop.caelestia.allowSuspend.";
            }
            {
              assertion = vpn.selectedProvider == null || lib.any (provider: provider.id == vpn.selectedProvider) vpn.providers;
              message = "Caelestia's selected VPN provider must be registered in local.desktop.caelestia.vpn.providers.";
            }
            {
              assertion = let
                ids = map (provider: provider.id) vpn.providers;
              in
                lib.length ids == lib.length (lib.unique ids);
              message = "Caelestia VPN provider identifiers must be unique.";
            }
          ];

          programs.caelestia = {
            enable = true;
            cli.enable = true;
            systemd = {
              enable = true;
              target = "graphical-session.target";
            };

            settings = {
              general.apps = {
                terminal = ["kitty"];
              };
              general.idle = {
                lockBeforeSleep = true;
                inhibitWhenAudio = true;
                timeouts =
                  [
                    {
                      timeout = cfg.idle.lockAfter;
                      idleAction = "lock";
                    }
                    {
                      timeout = cfg.idle.screensOffAfter;
                      idleAction = "dpms off";
                      returnAction = "dpms on";
                    }
                  ]
                  ++ lib.optional (cfg.idle.suspendAfter != null) {
                    timeout = cfg.idle.suspendAfter;
                    idleAction = ["suspend"];
                    inhibitWhenCharging = !cfg.idle.suspendOnAC;
                  };
              };
              # UPower owns critical-battery actions, including when the shell
              # is not running. The shell otherwise unconditionally hibernates.
              general.battery.criticalLevel = -1;
              background.desktopClock = {
                enabled = true;
                background.enabled = true;
                shadow.enabled = true;
              };
              paths.wallpaperDir = cfg.wallpaperDir;
              bar = {
                inherit (cfg) excludedScreens;
                persistent = true;
                status.showBattery = cfg.showBattery;
                scrollActions.brightness = cfg.showBrightness;
              };
              osd = {
                enableMicrophone = true;
                enableBrightness = cfg.showBrightness;
              };
              utilities = {
                vpn =
                  {
                    enabled = true;
                  }
                  // lib.optionalAttrs (vpn.providers != []) {
                    provider = vpn.providers;
                  }
                  // lib.optionalAttrs (vpn.selectedProvider != null) {
                    selectedProvider = vpn.selectedProvider;
                  };
              };
            };
          };

          # Keep upstream's generated source (also used for restart triggers),
          # but replace its store symlink with a writable copy after activation.
          xdg.configFile."caelestia/shell.json" = {
            enable = !cfg.writableSettings;
            # Also support switching back from a writable regular file.
            force = true;
          };
          home.activation.caelestiaWritableSettings = lib.mkIf cfg.writableSettings (
            lib.hm.dag.entryAfter ["linkGeneration"] ''
              settings=${lib.escapeShellArg "${config.xdg.configHome}/caelestia/shell.json"}
              applied=${lib.escapeShellArg "${config.xdg.stateHome}/caelestia/nix-shell.json"}
              defaults=${config.xdg.configFile."caelestia/shell.json".source}
              if [[ -L "$settings" || ! -f "$settings" ]] || ! ${pkgs.coreutils}/bin/cmp -s "$defaults" "$applied"; then
                if [[ -f "$settings" && ! -L "$settings" ]]; then
                  run ${pkgs.coreutils}/bin/cp -- "$settings" "$settings.before-nix"
                fi
                run ${pkgs.coreutils}/bin/rm -f -- "$settings"
                run ${pkgs.coreutils}/bin/install -Dm600 "$defaults" "$settings"
                run ${pkgs.coreutils}/bin/install -Dm600 "$defaults" "$applied"
              fi
            ''
          );

          systemd.user.services.caelestia.Service.Slice = lib.mkForce "session-graphical.slice";

          home.packages = with pkgs; [
            brightnessctl
            hyprpicker
            libnotify
            playerctl
          ];

          wayland.windowManager.hyprland.settings = {
            bind = lib.mkAfter [
              "$mod, D, global, caelestia:launcher"
              "$mod, L, global, caelestia:lock"
              "$mod, A, global, caelestia:picker open"
              ", XF86AudioPlay, exec, playerctl play-pause"
              ", XF86AudioNext, exec, playerctl next"
              ", XF86AudioPrev, exec, playerctl previous"
            ];
            bindel = lib.mkAfter ([
                ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
                ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ]
              ++ lib.optionals cfg.showBrightness [
                ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
                ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
              ]);
            bindl = lib.mkAfter [
              ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ];
            misc.force_default_wallpaper = 0;
          };
        };
      };
    };
  };
}

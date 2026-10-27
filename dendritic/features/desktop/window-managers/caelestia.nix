{
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
        options.local.desktop.caelestia.allowSuspend = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Allow system sleep. Disable on machines with unreliable resume.";
        };

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
      in {
        imports = [inputs.caelestia-shell.homeManagerModules.default];

        options.local.desktop.caelestia = {
          enable = lib.mkEnableOption "enables caelstia shell";
          wallpaperDir = lib.mkOption {
            type = lib.types.singleLineStr;
            default = "~/Pictures/Wallpapers";
            description = "where your wallpapers will be sourced";
          };
          showBattery = lib.mkEnableOption "shows battery in left sidebar";
          showBrightness = lib.mkEnableOption "shows brightness slider in right sidebar";
          writableSettings = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Use a writable shell.json so the settings UI can save changes.
              UI changes persist until the generated Nix settings change; then
              the previous file is backed up as shell.json.before-nix and the
              new Nix settings are applied.
            '';
          };
          idle = {
            lockAfter = lib.mkOption {
              type = lib.types.ints.positive;
              default = 180;
              description = "Idle seconds before locking the session.";
            };
            screensOffAfter = lib.mkOption {
              type = lib.types.ints.positive;
              default = 300;
              description = "Idle seconds before turning displays off (DPMS, not system sleep).";
            };
            suspendAfter = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = "Idle seconds before suspending, or null to disable automatic suspend.";
            };
            suspendOnAC = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Also automatically suspend while connected to external power.";
            };
          };
          excludedScreens = lib.mkOption {
            type = lib.types.listOf lib.types.singleLineStr;
            default = [];
            example = ["HDMI-A-1" "HDMI-A-2"];
            description = "Screens to not show the taskbar";
          };
        };

        config = lib.mkIf cfg.enable {
          assertions = [
            {
              assertion = cfg.idle.suspendAfter == null || osConfig.local.desktop.caelestia.allowSuspend;
              message = "Caelestia idle suspend requires local.desktop.caelestia.allowSuspend.";
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
                  // lib.optionalAttrs (osConfig.local.wireguard.enable or false) {
                    selectedProvider = lib.mkDefault "home-wireguard";
                    provider = [
                      {
                        id = "home-wireguard";
                        name = "wireguard";
                        displayName = "Home";
                        interface = "wg0";
                        # This profile belongs to NetworkManager, not wg-quick.
                        connectCmd = ["${pkgs.networkmanager}/bin/nmcli" "connection" "up" "id" "wg0"];
                        disconnectCmd = ["${pkgs.networkmanager}/bin/nmcli" "connection" "down" "id" "wg0"];
                      }
                    ];
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

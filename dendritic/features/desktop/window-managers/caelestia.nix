{
  flake-file.inputs.caelestia-shell = {
    url = "github:caelestia-dots/shell";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  flake.aspects = {aspects, ...}: {
    caelestia = {
      description = "Desktop build with caelestia shell on hyprland.";
      includes = [aspects.hyprland];

      homeManager = {
        config,
        lib,
        inputs,
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
          excludedScreens = lib.mkOption {
            type = lib.types.listOf lib.types.singleLineStr;
            default = [];
            example = ["HDMI-A-1" "HDMI-A-2"];
            description = "Screens to not show the taskbar";
          };
        };

        config = lib.mkIf cfg.enable {
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
              };
              osd = {
                enableMicrophone = true;
                enableBrightness = cfg.showBrightness;
              };
              utilities = {
                vpn = {
                  enabled = true;
                };
              };
            };
          };

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
            bindel = lib.mkAfter [
              ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
              ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
            ];
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

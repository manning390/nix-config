{
  flake.aspects = {aspects, ...}: {
    caelestia = {
      description = "Desktop build with caelestia shell on hyprland.";
      includes = [aspects.hyprland];

      homeManager = {
        config,
        lib,
        inputs,
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
        # config = {
          programs.caelestia = {
            enable = true;
            cli.enable = true;

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
              estate = {
                  settings = {
                    vpnChanged = true;
                  };
                };
              vpn = {
                  enabled = true;
                  provider = [
                    {
                      name = "wireguard";
                      interface = "wg-home";
                      displayName = "Home";
                    }
                  ];
                };
            };
          };
        };
      };
    };
  };
}

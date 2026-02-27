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
        };

        config = lib.mkIf cfg.enable {
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
                excludedScreens = ["HDMI-A-1" "HDMI-A-2"];
                persistent = true;
                status.showBattery = cfg.showBattery;
              };
              osd = {
                enableMicrophone = true;
                enableBrightness = cfg.showBrightness;
              };
            };
          };
        };
      };
    };
  };
}

{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.local.desktop.caelestia;
in {
  flake.aspects = {aspects, ...}: {
    caelestia = {
      description = "Desktop build with caelestia shell on hyprland.";
      includes = with aspects; [hyprland];

      homeManager = {
        imports = [inputs.caelestia-shell.homeManagerModules.default];
        options.local.desktop.caelestia = {
          enable = lib.mkEnableOption "enables caelstia shell";
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
              paths.wallpaperDir = "~/Pictures/Wallpapers/";
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

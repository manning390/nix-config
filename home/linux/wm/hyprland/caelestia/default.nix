{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.custom.wm.caelestia;
in {
  imports = [inputs.caelestia-shell.homeManagerModules.default];

  options.custom.wm.caelestia = {
    enable = lib.mkEnableOption "enables caelestia shell";
    showBattery = lib.mkEnableOption "shows battery in bar";
  };

  config = lib.mkIf cfg.enable {
    programs.caelestia = {
      enable = true;
      cli = {
        enable = true;
      };

      settings = {
        paths.wallpaperDir = "~/Pictures/Wallpapers/";
        bar.status.showBattery = cfg.showBattery;
      };
    };
  };
}

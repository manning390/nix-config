{
  pkgs,
  config,
  lib,
  ...
}: let
  wallpapers = [
    "ign_circuit"
    "nixos"
    "ign_wave"
  ];
  monitors = [
    "HDMI-A-1"
    "DP-1"
    "HDMI-A-2"
  ];
  getWallpaper = name: pkgs.nordic-wallpapers.${name};
  wallpaperPath = name: "${getWallpaper name}/${name}.png";
in {
  options.hyprpaper.enable = lib.mkEnableOption "enables hyprpaper";

  config = lib.mkIf config.hyprpaper.enable {
    home.packages = map getWallpaper wallpapers ++ [ pkgs.hyprpaper ];

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = map wallpaperPath wallpapers;
        wallpaper = lib.zipListsWith (monitor: wallpaper:
          "${monitor},${wallpaperPath wallpaper}"
        ) monitors wallpapers;
        splash = false;
      };
    };

    wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
      "uwsm app -- hyprpaper"
    ];
  };
}

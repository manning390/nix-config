{
  pkgs,
  config,
  lib,
  ...
}: let
  wallpapers = [
    "ign_circuit"
    # "ign_access_control"
    "ign_city"
    "ign_wave"
  ];
  monitors = [
    "HDMI-A-1"
    "DP-1"
    "HDMI-A-2"
  ];
in {
  options = {
    hyprpaper.enable = lib.mkEnableOption "enables hyprpaper";
  };

  config = lib.mkIf config.hyprpaper.enable {
    home.packages =
      (builtins.map (name: pkgs.nordic-wallpapers.wallpapers.${name}) wallpapers)
      ++ [
        pkgs.hyprpaper
      ];

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = lib.map (name:
          "${config.home.homeDirectory}/share/wallpapers/${name}.png")
          wallpapers;
        wallpaper = lib.zipListsWith (monitor: wallpaper:
          "${monitor},${config.home.homeDirectory}/share/wallpapers/${wallpaper}.png")
          monitors wallpapers;
        splash = true;
      };
    };

    wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
      "uwsm app -- hyprpaper"
    ];
  };
}

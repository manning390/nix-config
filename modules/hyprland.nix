{
  pkgs,
  inputs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  environment.systemPackages = with pkgs;
    [
      (pkgs.waybar.overrideAttrs (oldAttrs: {mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];})) # Bar
      mako # System messages
      rofi-wayland # Application launcher
      hyprpaper # Wallpaper
      hyprlock # lock screen
      hyprcursor # Better cursors
      hypridle # System idle
      hyprpicker # Color picker
      hyprpolkitagent # Escalate priviledges
      nwg-look # GTK3 settings editor
      glxinfo # Wanted by waybar config, GPU info
      bc # Wanted by waybar, calculator cmd
      playerctl
      brightnessctl
    ]
    ++ [
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast # or any other package
    ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-hyprland];
}

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
      rofi-wayland # Application launcher
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
      mako
    ]
    ++ [
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast # or any other package
    ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-hyprland];
}

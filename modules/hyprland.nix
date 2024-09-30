{
  pkgs,
  inputs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs;
    [
      (pkgs.waybar.overrideAttrs (oldAttrs: {mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];})) # Bar
      mako # System messages
      # libnotify # required by mako
      rofi-wayland # Application launcher
      hyprpaper # Wallpaper
      hyprlock
      hyprcursor
      hypridle
      nwg-look
    ]
    ++ [
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast # or any other package
    ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
}

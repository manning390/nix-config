{...}: {
  imports = [
    ../../home/linux/desktop.nix
  ];

  wayland.windowManager.hyprland.settings.input = {
    kb_options = "caps:swapescape";
  }; 

  
  home.stateVersion = "24.05";
}

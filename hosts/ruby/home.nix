{config, ...}: {
  imports = [
    ../../home/linux/desktop.nix
  ];

  # wayland.windowManager.hyprland.settings.input = {
  #   kb_layout = "us";
  #   kb_variant = "colemak_dh";
  #   kb_options = "caps:swapescape";
  # };
  #
  # config.services.xserver = {
  #   xkb.layout = "us";
  #   xkb.variant = "colemak_dh";
  #   xkb.options = "caps:swapescape";
  # };

  config.home.stateVersion = "24.05";
}

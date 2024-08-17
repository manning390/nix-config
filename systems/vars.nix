# This file links the various system configs and home configs to the appropriate hosts
let
  desktop_base_modules = {
    nixos-modules = [
      ../modules/nixos/desktop.nix
    ];
    home-modules = [
      ../home/linux/desktop.nix
    ];
  };
in {
  # NixOs Systems
  sentry_modules_hyprland = {
    nixos-modules = [
      ../hosts/sentry
      {
        modules.desktop.wayland.enable = true;
      }
    ] ++ desktop_base_modules.nixos-modules;
    home-modules = [
      ../hosts/sentry/home.nix
      {modules.desktop.hyprland.enable = true;}
    ] ++ desktop_base_modules.home-modules;
  };
  # Darwin System
  # none atm, lol
}

let
  desktop_base_modules = {
    nixos-modules = [
      ../modules/nixos/desktop.nix
    ];
    home-modules.imports = [
      ../home/linux/desktop.nix
    ];
  };
in {
  # NixOs Systems
  sentry_modules_hyprland = {
    nixos-modules = [
      ../hosts/sentry
    ] ++ desktop_base_modules.nixos-modules;
    home-module.imports = [
      ../hosts/sentry/home.nix
    ] ++ desktop_base_modules.home-module.imports;
  };
  # Darwin System
  # none atm, lol
}

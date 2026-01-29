{
  lib,
  vars,
  ...
}: {
  imports = lib.custom.scanPaths ./.;

  home = {
    username = vars.username;
    homeDirectory = "/home/${vars.username}";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

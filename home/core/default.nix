{
  mylib,
  myvars,
  ...
}: {
  imports = mylib.scanPaths ./.;

  home = {
    username = myvars.username;
    homeDirectory = "/home/${myvars.username}";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

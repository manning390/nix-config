{config, ...}: {
  imports = [
    ../../home/linux/desktop.nix
  ];

  config.home.stateVersion = "24.05";
}

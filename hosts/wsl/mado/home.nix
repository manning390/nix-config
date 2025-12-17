{lib, ...}: {
  imports = builtins.map lib.custom.relativeToRoot [
    "home/core"
  ];

  home.stateVersion = "25.05";
}

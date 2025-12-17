{lib, ...}: {
  imports = [ ] ++ builtins.map lib.custom.relativeToRoot [
    "home/linux/desktop.nix"
  ];
  home.stateVersion = "23.11";
}

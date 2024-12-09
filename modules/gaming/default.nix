{pkgs, lib, ...}: {
  imports = [
    ./ffxiv.nix
    ./steam.nix
    ./godot.nix
  ];

  ffxiv.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault true;
}

{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./ffxiv.nix
    ./steam.nix
    ./godot.nix
  ];

  custom = {
    ffxiv.enable = lib.mkDefault true;
    steam.enable = lib.mkDefault true;
  };
}

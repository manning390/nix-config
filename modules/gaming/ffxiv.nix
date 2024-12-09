{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    ffxiv.enable = lib.mkEnableOption "enables ffxiv";
  };

  config = lib.mkIf config.ffxiv.enable {
    environment.systemPackages = with pkgs; [
      xivlauncher
    ];
  };
}

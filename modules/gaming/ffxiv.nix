{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.ffxiv.enable = lib.mkEnableOption "enables ffxiv";

  config = lib.mkIf config.custom.ffxiv.enable {
    environment.systemPackages = with pkgs; [
      xivlauncher
    ];
  };
}

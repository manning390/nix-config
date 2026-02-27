{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.ffxiv.enable = lib.mkEnableOption "enables ffxiv";

  config = lib.mkIf config.local.ffxiv.enable {
    environment.systemPackages = with pkgs; [
      xivlauncher
    ];
  };
}

{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    obs.enable = lib.mkEnableOption "enables obs studio";
  };

  config = lib.mkIf config.obss.enable {
    environment.systemPackages = [
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-background-removal
          obs-pipewire-audio-capture
        ];
      })
    ];
  };
}

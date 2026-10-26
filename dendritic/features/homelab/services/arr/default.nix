{
  flake.aspects = {aspects, ...}: {
    arr = {
      description = "Media management, requests, subtitles, and playback";
      includes = with aspects; [sonarr radarr prowlarr bazarr seerr jellyfin];

      nixos = {
        config,
        lib,
        ...
      }: let
        homelab = config.homelab;
        cfg = homelab.services;
        directoryRule = path: "d ${path} 0775 ${homelab.user} ${homelab.group} - -";
      in {
        # Create each shared library once, even when several apps use it.
        config = lib.mkMerge [
          (lib.mkIf (cfg.radarr.enable || cfg.bazarr.enable || cfg.jellyfin.enable) {
            systemd.tmpfiles.rules = [(directoryRule cfg.radarr.libraryDir)];
          })
          (lib.mkIf (cfg.sonarr.enable || cfg.bazarr.enable || cfg.jellyfin.enable) {
            systemd.tmpfiles.rules = [(directoryRule cfg.sonarr.libraryDir)];
          })
        ];
      };
    };
  };
}

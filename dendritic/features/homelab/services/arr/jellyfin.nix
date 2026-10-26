{
  flake.aspects.jellyfin = {
    description = "Movie and TV streaming";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.jellyfin;
      port = 8096;
      libraryDirs = [homelab.services.radarr.libraryDir homelab.services.sonarr.libraryDir];
    in {
      options.homelab.services.jellyfin = {
        enable = lib.mkEnableOption "Jellyfin";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "jellyfin.${homelab.baseDomain}";
          description = "The hostname Jellyfin is available at.";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Jellyfin";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "jellyfin.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Movie and TV streaming";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Media";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices = ["jellyfin.service"];
        services.jellyfin = {
          enable = true;
          openFirewall = false;
          user = homelab.user;
          group = homelab.group;
        };
        systemd.services.jellyfin.unitConfig.RequiresMountsFor = libraryDirs;
        services.caddy.virtualHosts."${cfg.url}".extraConfig = ''
          tls internal
          reverse_proxy http://127.0.0.1:${toString port}
        '';
      };
    };
  };
}

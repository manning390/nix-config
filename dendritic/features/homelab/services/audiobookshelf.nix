{
  flake.aspects.audiobookshelf = {
    description = "Self-hosted audiobook and podcast player";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.audiobookshelf;
    in {
      options.homelab.services.audiobookshelf = {
        enable = lib.mkEnableOption "Enable Audiobookshelf";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "audiobooks.${homelab.baseDomain}";
          description = "The hostname Audiobookshelf is available at.";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 8113;
          description = "The loopback HTTP port used by the Caddy reverse proxy.";
        };
        audiobooksDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.mounts.merged}/Audiobooks";
          description = "Audiobook library directory. Select this path when creating a library in the web interface.";
        };
        podcastsDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.mounts.merged}/Podcasts";
          description = "Podcast library and download directory. Select this path when creating a library in the web interface.";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Audiobookshelf";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "audiobookshelf.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Audiobook and podcast player";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Media";
        };
      };

      config = lib.mkIf cfg.enable {
        # Capture the database/metadata in /var/lib together with the media tiers.
        homelab.backups.quiesceServices = ["audiobookshelf.service"];

        services.audiobookshelf = {
          enable = true;
          user = homelab.user;
          group = homelab.group;
          host = "127.0.0.1";
          port = cfg.port;
        };

        systemd.tmpfiles.rules = [
          "d ${cfg.audiobooksDir} 0775 ${homelab.user} ${homelab.group} - -"
          "d ${cfg.podcastsDir} 0775 ${homelab.user} ${homelab.group} - -"
        ];
        systemd.services.audiobookshelf.unitConfig.RequiresMountsFor = [
          cfg.audiobooksDir
          cfg.podcastsDir
        ];

        services.caddy.virtualHosts."${cfg.url}".extraConfig = ''
          tls internal
          reverse_proxy http://127.0.0.1:${toString cfg.port}
        '';
      };
    };
  };
}

{
  flake.aspects.deluge = {
    description = "Self-hosted BitTorrent client";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.deluge;
      webPort = 8112;
    in {
      options.homelab.services.deluge = {
        enable = lib.mkEnableOption "Enable Deluge";
        downloadsDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.mounts.merged}/Downloads/torrents";
          description = "Shared torrent download directory. Select this path in Deluge's web preferences; existing stateful settings are not overwritten.";
        };
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "deluge.${homelab.baseDomain}";
          description = "The URL Deluge is available at";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Deluge";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "deluge.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Torrent client";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Downloads";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices =
          ["deluged.service"]
          ++ lib.optional config.services.deluge.web.enable "delugeweb.service";

        services.deluge = {
          enable = true;
          user = homelab.user;
          group = homelab.group;
          web = {
            enable = true;
            port = webPort;
          };
        };

        systemd.tmpfiles.rules = [
          "d ${cfg.downloadsDir} 0775 ${homelab.user} ${homelab.group} - -"
        ];
        systemd.services.deluged.unitConfig.RequiresMountsFor = [cfg.downloadsDir];

        services.caddy.virtualHosts."${cfg.url}" = {
          extraConfig = ''
            tls internal
            reverse_proxy http://127.0.0.1:${toString webPort}
          '';
        };
      };
    };
  };
}

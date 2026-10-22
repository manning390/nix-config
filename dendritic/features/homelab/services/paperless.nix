{
  flake.aspects.paperless = {
    description = "Self-hosted document management system";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.paperless;
    in {
      options.homelab.services.paperless = {
        enable = lib.mkEnableOption "Enable Paperless-ngx";
        mediaDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.mounts.merged}/Documents/Paperless/Documents";
          description = "Directory for Paperless-ngx documents and media";
        };
        consumptionDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.mounts.merged}/Documents/Paperless/Import";
          description = "Directory watched by Paperless-ngx for new documents";
        };
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "paperless.${homelab.baseDomain}";
          description = "The URL Paperless-ngx is available at";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Paperless-ngx";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "paperless.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Document management system";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Services";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices =
          [
            "paperless-scheduler.service"
            "paperless-task-queue.service"
            "paperless-consumer.service"
            "paperless-web.service"
          ]
          ++ lib.optional config.services.paperless.exporter.enable "paperless-exporter.service"
          ++ lib.optional config.services.paperless.database.createLocally "postgresql.service"
          ++ lib.optional (config.services.redis.servers.paperless.enable or false) "redis-paperless.service";

        services.paperless = {
          enable = true;
          user = homelab.user;
          mediaDir = toString cfg.mediaDir;
          consumptionDir = toString cfg.consumptionDir;
          consumptionDirIsPublic = false;
          settings = {
            PAPERLESS_URL = "https://${cfg.url}";
            PAPERLESS_CONSUMER_IGNORE_PATTERN = [
              ".DS_STORE/*"
              "desktop.ini"
            ];
            PAPERLESS_OCR_LANGUAGE = "eng";
          };
        };

        systemd.tmpfiles.rules = [
          "d ${cfg.mediaDir} 0775 ${homelab.user} ${homelab.group} - -"
          "d ${cfg.consumptionDir} 0775 ${homelab.user} ${homelab.group} - -"
        ];
        systemd.services = lib.genAttrs [
          "paperless-scheduler"
          "paperless-task-queue"
          "paperless-consumer"
          "paperless-web"
        ] (_: {
          unitConfig.RequiresMountsFor = [
            cfg.mediaDir
            cfg.consumptionDir
          ];
        });

        services.caddy.virtualHosts."${cfg.url}" = {
          extraConfig = ''
            tls internal
            reverse_proxy http://127.0.0.1:${toString config.services.paperless.port}
          '';
        };
      };
    };
  };
}

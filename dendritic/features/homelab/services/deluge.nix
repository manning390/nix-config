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
        services.deluge = {
          enable = true;
          user = homelab.user;
          group = homelab.group;
          web = {
            enable = true;
            port = webPort;
          };
        };

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

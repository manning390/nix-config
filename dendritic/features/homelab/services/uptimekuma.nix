{
  flake.aspects.uptimekuma = {
    description = "Self-hosted service monitoring tool";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.uptimekuma;
      port = 3001;
    in {
      options.homelab.services.uptimekuma = {
        enable = lib.mkEnableOption "Enable Uptime Kuma";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "uptime.${homelab.baseDomain}";
          description = "The URL Uptime Kuma is available at";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Uptime Kuma";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "uptime-kuma.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Service monitoring tool";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Services";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices = ["uptime-kuma.service"];

        services.uptime-kuma = {
          enable = true;
          settings = {
            HOST = "127.0.0.1";
            PORT = toString port;
          };
        };

        services.caddy.virtualHosts."${cfg.url}" = {
          extraConfig = ''
            tls internal
            reverse_proxy http://127.0.0.1:${toString port}
          '';
        };
      };
    };
  };
}

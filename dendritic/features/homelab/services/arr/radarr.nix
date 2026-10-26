{
  flake.aspects.radarr = {
    description = "Movie collection manager";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.radarr;
      port = 7878;
    in {
      options.homelab.services.radarr = {
        enable = lib.mkEnableOption "Radarr";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "radarr.${homelab.baseDomain}";
          description = "The hostname Radarr is available at.";
        };
        libraryDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.mounts.merged}/Media/Movies";
          description = "Movie library root shared by Radarr, Bazarr, and Jellyfin.";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Radarr";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "radarr.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Movie collection manager";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Arr";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices = ["radarr.service"];
        services.radarr = {
          enable = true;
          openFirewall = false;
          user = homelab.user;
          group = homelab.group;
          settings.server.bindaddress = "127.0.0.1";
        };
        systemd.services.radarr = {
          unitConfig.RequiresMountsFor = [cfg.libraryDir homelab.services.deluge.downloadsDir];
          serviceConfig.UMask = lib.mkForce "0002";
        };
        services.caddy.virtualHosts."${cfg.url}".extraConfig = ''
          tls internal
          reverse_proxy http://127.0.0.1:${toString port}
        '';
      };
    };
  };
}

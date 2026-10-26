{
  flake.aspects.sonarr = {
    description = "TV show collection manager";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.sonarr;
      port = 8989;
    in {
      options.homelab.services.sonarr = {
        enable = lib.mkEnableOption "Sonarr";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "sonarr.${homelab.baseDomain}";
          description = "The hostname Sonarr is available at.";
        };
        libraryDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.mounts.merged}/Media/TV";
          description = "TV library root shared by Sonarr, Bazarr, and Jellyfin.";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Sonarr";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "sonarr.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "TV show collection manager";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Arr";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices = ["sonarr.service"];
        services.sonarr = {
          enable = true;
          openFirewall = false;
          user = homelab.user;
          group = homelab.group;
          settings.server.bindaddress = "127.0.0.1";
        };
        systemd.services.sonarr = {
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

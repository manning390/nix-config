{
  flake.aspects.bazarr = {
    description = "Subtitle manager";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.bazarr;
      port = 6767;
      libraryDirs = [homelab.services.radarr.libraryDir homelab.services.sonarr.libraryDir];
    in {
      options.homelab.services.bazarr = {
        enable = lib.mkEnableOption "Bazarr";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "bazarr.${homelab.baseDomain}";
          description = "The hostname Bazarr is available at.";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Bazarr";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "bazarr.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Subtitle manager";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Arr";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices = ["bazarr.service"];
        services.bazarr = {
          enable = true;
          openFirewall = false;
          user = homelab.user;
          group = homelab.group;
        };
        systemd.services.bazarr = {
          unitConfig.RequiresMountsFor = libraryDirs;
          serviceConfig.UMask = "0002";
        };
        services.caddy.virtualHosts."${cfg.url}".extraConfig = ''
          tls internal
          reverse_proxy http://127.0.0.1:${toString port}
        '';
      };
    };
  };
}

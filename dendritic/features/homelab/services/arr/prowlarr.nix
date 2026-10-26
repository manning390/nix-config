{
  flake.aspects.prowlarr = {
    description = "Indexer manager";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.prowlarr;
      port = 9696;
    in {
      options.homelab.services.prowlarr = {
        enable = lib.mkEnableOption "Prowlarr";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "prowlarr.${homelab.baseDomain}";
          description = "The hostname Prowlarr is available at.";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Prowlarr";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "prowlarr.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Indexer manager";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Arr";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices = ["prowlarr.service"];
        # Prowlarr needs no library access; keep NixOS's DynamicUser sandbox.
        services.prowlarr = {
          enable = true;
          openFirewall = false;
          settings.server.bindaddress = "127.0.0.1";
        };
        services.caddy.virtualHosts."${cfg.url}".extraConfig = ''
          tls internal
          reverse_proxy http://127.0.0.1:${toString port}
        '';
      };
    };
  };
}

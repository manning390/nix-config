{
  flake.aspects.seerr = {
    description = "Media discovery and requests";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.seerr;
      port = 5055;
    in {
      options.homelab.services.seerr = {
        enable = lib.mkEnableOption "Seerr";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "seerr.${homelab.baseDomain}";
          description = "The hostname Seerr is available at.";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Seerr";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "seerr.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Media discovery and requests";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Arr";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices = ["seerr.service"];
        # Keep its DynamicUser and stateVersion-dependent state directory.
        services.seerr = {
          enable = true;
          openFirewall = false;
          inherit port;
        };
        services.caddy.virtualHosts."${cfg.url}".extraConfig = ''
          tls internal
          reverse_proxy http://127.0.0.1:${toString port}
        '';
      };
    };
  };
}

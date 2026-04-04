{
  flake.aspects.immich = {
    description = "Self-hosted photo and video management solution";

    nixos = {config,pkgs,lib,...}: let
      homelab = config.homelab;
      cfg = homelab.services.immich;
    in {
      options.homelab.services.immich = {
        enable = lib.mkEnableOption "Enable Immich";
        user = lib.mkOption {
          default = "immich";
          type = lib.types.singleLineStr;
          description = "User to run the Immich container as";
        };
        group = lib.mkOption {
          default = config.homelab.group;
          type = lib.types.singleLineStr;
          description = "Group to run the Immich container as";
        };
        monitoredServices = lib.mkOption {
          type = lib.types.listOf lib.types.singleLineStr;
          default = [
            "immich-server"
            # "immich-machine-learning"
          ];
        };
        mediaDir = lib.mkOption {
          type = lib.types.path;
          default = "${homelab.mounts.fast}/Photos/Immich";
        };
        url = lib.mkOption {
          type = lib.types.sinleLineStr;
          default = "photos.${homelab.baseDomain}";
        };
        homepage.name = lib.mkOption {
          type = lib.types.sinleLineStr;
          default = "Immich";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Self-hosted photo and video management solution";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Media";
        };
      };
      config = lib.mkIf cfg.enable {
        systemd.tmpfiles.rules = [ "d ${cfg.mediaDir} 0775 ${cfg.user} ${cfg.group} - -"];
        users.users.immich.extraGroups = [
          "video"
          "render"
        ];
        services.immich = {
          enable = true;
          user = cfg.user;
          group = cfg.group;
          port = 2283;
          mediaLocation = "${cfg.mediaDir}";
        };
        services.caddy.virtualHosts."${cfg.url}" = {
          # useACMEHost = homelab.baseDomain;
          extraConfig = ''
            tls internal
            reverse_proxy http://${config.services.immich.host}:${toString config.services.immich.port}
          '';
        };
      };
    };
  };
}

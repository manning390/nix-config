{
  flake.aspects.filebrowser = {
    description = "Web application for managing files and directories of enabled machine";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.filebrowser;
    in {
      options.homelab.services.filebrowser = {
        enable = lib.mkEnableOption "Enable filebrowser";
        user = lib.mkOption {
          default = config.homelab.user;
          type = lib.types.singleLineStr;
          description = "User to run the Filebrowser as";
        };
        group = lib.mkOption {
          default = config.homelab.group;
          type = lib.types.singleLineStr;
          description = "Group to run the Filebrowser as";
        };
        port = lib.mkOption {
          default = 8080;
          type = lib.types.number;
          description = "The port the local service to listens on";
        };
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "files.${homelab.baseDomain}";
          description = "The url the service is available on";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Files";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "filebrowser.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Self-hosted filebrowser";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Media";
        };
      };
      config = lib.mkIf cfg.enable {
        services.filebrowser = {
          enable = true;
          openFirewall = true;
          user = cfg.user;
          group = cfg.group;
          settings.port = cfg.port;
        };
        services.caddy.virtualHosts."${cfg.url}" = {
          extraConfig = ''
            tls internal
            reverse_proxy http://${config.services.filebrowser.settings.address}:${toString config.services.filebrowser.settings.port}
          '';
        };
      };
    };
  };
}

{
  flake.aspects.forgejo = {
    description = "Self-hosted Git service and software forge";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.forgejo;
    in {
      options.homelab.services.forgejo = {
        enable = lib.mkEnableOption "Enable Forgejo";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "git.${homelab.baseDomain}";
          description = "The URL Forgejo is available at";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 3000;
          description = "The local HTTP port Forgejo listens on";
        };
        sshPort = lib.mkOption {
          type = lib.types.port;
          default = 2222;
          description = "The SSH port Forgejo listens on and advertises for clone URLs";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Forgejo";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "forgejo.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Self-hosted Git service and software forge";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Services";
        };
      };

      config = lib.mkIf cfg.enable {
        networking.firewall.allowedTCPPorts = [cfg.sshPort];

        services.forgejo = {
          enable = true;
          settings = {
            server = {
              DOMAIN = cfg.url;
              ROOT_URL = "https://${cfg.url}/";
              HTTP_ADDR = "127.0.0.1";
              HTTP_PORT = cfg.port;
              SSH_DOMAIN = cfg.url;
              SSH_PORT = cfg.sshPort;
              SSH_LISTEN_PORT = cfg.sshPort;
              START_SSH_SERVER = true;
            };
            service.DISABLE_REGISTRATION = true;
            repository.ENABLE_PUSH_CREATE_USER = true;
          };
        };

        environment.systemPackages = [config.services.forgejo.package];

        services.caddy.virtualHosts."${cfg.url}" = {
          extraConfig = ''
            tls internal
            reverse_proxy http://127.0.0.1:${toString cfg.port}
          '';
        };
      };
    };
  };
}

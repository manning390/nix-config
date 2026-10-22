{
  flake.aspects.memos = {
    description = "Self-hosted personal notes and memo timeline";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.memos;
    in {
      options.homelab.services.memos = {
        enable = lib.mkEnableOption "Enable Memos";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "memos.${homelab.baseDomain}";
          description = "The URL Memos is available at";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 5230;
          description = "The local HTTP port Memos listens on";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Memos";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "memos.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Self-hosted personal notes and memo timeline";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Services";
        };
      };

      config = lib.mkIf cfg.enable {
        homelab.backups.quiesceServices = ["memos.service"];

        services.memos = {
          enable = true;
          settings = {
            # This option replaces the NixOS module's default settings as a whole.
            MEMOS_MODE = "prod";
            MEMOS_DATA = config.services.memos.dataDir;
            MEMOS_DRIVER = "sqlite";
            MEMOS_ADDR = "127.0.0.1";
            MEMOS_PORT = toString cfg.port;
            MEMOS_INSTANCE_URL = "https://${cfg.url}";
          };
        };

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

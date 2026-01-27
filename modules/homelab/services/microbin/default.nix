{
  config,
  pkgs,
  lib,
  ...
}: let
  # nordHighlight = builtins.toFile "nord.css"
  service = "microbin";
  cfg = config.homelab.services.${service};
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable ${service}";
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/microbin";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "bin.${config.homelab.baseDomain}";
    };
    passwordFile = lib.mkOption {
      default = "";
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "microbin-secret.txt" '''
          MICROBIN_ADMIN_USERNAME
          MICROBIN_ADMIN_PASSWORD
          MICROBIN_UPLOADER_PASSWORD
        '''
      '';
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Microbin";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "A minimal pastebin";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "microbin.png";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
    role = lib.mkOption {
      type = lib.types.enum [
        "client"
        "server"
      ];
      default = "client";
    };
  };
  config = let
    mkIfElse = p: yes: no:
      lib.mkMerge [
        (lib.mkIf p yes)
        (lib.mkIf (!p) no)
      ];
    addr = "127.0.0.1";
    port = 8069;
  in
    mkIfElse (cfg.role == "client")
    (lib.mkIf cfg.enable {
      services = {
        ${service} =
          {
            enable = true;
            settings = {
              MICROBIN_WIDE = true;
              MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB = 2048;
              MICROBIN_PUBLIC_PATH = "https://${cfg.url}/";
              MICROBIN_BIND = addr;
              MICROBIN_PORT = toString port;
              MICROBIN_HIDE_LOGO = true;
              MICROBIN_HIGHLIGHTSYNTAX = true;
              MICROBIN_HIDE_HEADER = true;
              MICROBIN_HIDE_FOOTER = true;
            };
          }
          // lib.attrsets.optionalAttrs (cfg.passwordFile != "") {
            passwordFile = cfg.passwordFile;
          };
        frp.settings.proxies = [
          {
            name = service;
            type = "tcp";
            localIP = addr;
            localPort = port;
            remotePort = port;
          }
        ];
      };
    })
    {
      services.caddy.virtualHosts."${cfg.url}" = {
        extraConfig = ''
          tls internal
          @noauth path /p/* /static/* file/* /static/highlight/*
          handle @noauth {
            reverse_procy http://${addr}:${toString port}
          }
        '';
      };
    };
}

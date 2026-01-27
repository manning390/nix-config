{
  config,
  pkgs,
  lib,
  ...
}: let
  nordHighlight = builtins.toFile "nord.css" (builtins.readFile ./nord.css);
  nordUi = builtins.toFile "nord_ui.css" (buitlins.readFile ./nord_ui.css);
  highlightJsNix = pkgs.fetchurl {
    url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/nix.min.js";
    hash = "sha256-j4dmtrr8qUODoICuOsgnj1ojTAmxbKe00mE5sfElC/I=";
  };
  highlightJs = pkgs.fetchurl {
    url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js";
    hash = "sha256-xKOZ3W9Ii8l6NUbjR2dHs+cUyZxXuUcxVMb7jSWbk4E=";
  };
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
      nixpkgs.overlays = with pkgs; [
        (_final: prev: {
          microbin = prev.microbin.overrideAttrs (
            _finalAttrs: _previousAttrs: {
              postPatch = ''
                cp ${nordHighlight} templates/assets/highlight/highlight.min.css
                cp ${highlightJs} templates/assets/highlight/highlight.min.js
                cp ${highlightJsNix} templates/assets/highlight/nix.min.js
                echo "" >> templates/assets/water.css
                cat ${nordUi} >> templates/assets/water.css
                sed -i "s#<option value=\"auto\">#<option value=\"auto\" selected>#" templates/index.html
                sed -i "s#highlight.min.js\"></script>#highlight.min.js\"></script><script type=\"text/javascript\" src=\"{{ args.public_path_as_str() }}/static/highlight/nix.min.js\"></script>#" templates/upload.html
              '';
            }
          );
        })
      ];
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
        # frp.settings.proxies = [
        #   {
        #     name = service;
        #     type = "tcp";
        #     localIP = addr;
        #     localPort = port;
        #     remotePort = port;
        #   }
        # ];
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

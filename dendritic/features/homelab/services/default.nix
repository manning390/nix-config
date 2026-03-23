{
  flake.aspects = {aspects, ...}: {
    services = {
      description = "Collection of aspects / modules for homelab services.";

      nixos = {
        config,
        lib,
        pkgs,
        ...
      }: {
        options.homelab = {
          services.enable = lib.mkEnableOption "Settings and services for the homelab";
        };
        networking.firewall.allowedTCPPorts = [80 443];
        environment.systemPackages = [pkgs.nss.tools];
        services.caddy = {
          enable = true;
          globalConfig = ''
            auto_https off
          '';
          virtualHosts = {
            "http://${config.homelab.baseDomain}" = {
              extraConfig = ''
                redir https://{host}{uri}
              '';
            };
            "http://*.${config.homelab.baseDomain}" = {
              extraConfig = ''
                redir https://{host}{uri}
              '';
            };
          };
        };
      };

      includes = with aspects; [
        immich
      ];
    };
  };
}

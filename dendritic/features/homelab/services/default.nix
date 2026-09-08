{
  flake.aspects = {aspects, ...}: {
    services = {
      description = "Collection of aspects / modules for homelab services.";

      nixos = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.homelab.services;
      in {
        options.homelab.services = {
          enable = lib.mkEnableOption "Settings and services for the homelab";
        };

        config = lib.mkIf cfg.enable {
          networking.firewall.allowedTCPPorts = [80 443];
          environment.systemPackages = [pkgs.nss.tools];
          services.caddy = {
            enable = true;
            globalConfig = ''
              pki {
                ca local {
                  name "Glaciem Homelab Local CA"
                }
              }
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

          # Caddy creates and persists the private CA material under /var/lib/caddy.
          # Export only its public root certificate so it can be installed in client
          # trust stores. The private key must never leave Glaciem.
          systemd.services.export-caddy-local-ca = {
            description = "Export Caddy local CA root certificate for client devices";
            wantedBy = ["multi-user.target"];
            requires = ["caddy.service"];
            after = ["caddy.service"];
            serviceConfig = {
              Type = "oneshot";
              User = "root";
            };
            script = ''
              root_ca=$(find /var/lib/caddy -path '*/pki/authorities/local/root.crt' -print -quit)
              test -n "$root_ca"
              install -D -m 0644 "$root_ca" /var/lib/caddy/local-ca/glaciem-homelab-root-ca.crt
            '';
          };
        };
      };

      includes = with aspects; [
        homepage
        immich
        microbin
      ];
    };
  };
}

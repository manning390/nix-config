{
  flake.aspects.pihole = {
    description = "Network-wide DNS resolver and ad blocker";

    nixos = {
      config,
      lib,
      ...
    }: let
      homelab = config.homelab;
      cfg = homelab.services.pihole;
      webPort = 8083;
    in {
      options.homelab.services.pihole = {
        enable = lib.mkEnableOption "Enable Pi-hole";
        url = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "dns.${homelab.baseDomain}";
          description = "The URL of the Pi-hole dashboard";
        };
        homepage.name = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Pi-hole";
        };
        homepage.icon = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "pi-hole.svg";
        };
        homepage.description = lib.mkOption {
          type = lib.types.str;
          default = "Network-wide DNS and ad blocking";
        };
        homepage.category = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "Services";
        };
      };

      config = lib.mkIf cfg.enable {
        services.pihole-ftl = {
          enable = true;
          openFirewallDNS = true;
          settings = {
            dns.upstreams = [
              "1.1.1.1"
              "1.0.0.1"
            ];

            # Resolve glaciem.home and every subdomain to Glaciem
            misc.dnsmasq_lines = lib.mkForce [
              "address=/glaciem.home/${config.local.lan.hosts.glaciem}"
            ];
          };
        };

        services.pihole-web = {
          enable = true;
          hostName = cfg.url;
          ports = [webPort];
        };

        services.caddy.virtualHosts."${cfg.url}" = {
          extraConfig = ''
            tls internal
            reverse_proxy http://127.0.0.1:${toString webPort}
          '';
        };
      };
    };
  };
}

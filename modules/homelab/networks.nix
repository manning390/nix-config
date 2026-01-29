{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.networks;
in {
  options.homelab.networks = {
    external = lib.mkOption {
      default = {};
      example = lib.literalExpression ''
        hostname = {
          address = "192.168.2.2";
          gateway = "192.168.1.1";
          interface = "enp1s0";
        };
      '';
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            address = lib.mkOption {
              example = "192.168.2.2";
              type = lib.types.str;
            };
            gateway = lib.mkOption {
              example = "192.168.1.1";
              type = lib.types.str;
            };
            interface = lib.mkOption {
              example = "enp1s0";
              type = lib.types.str;
            };
          };
        }
      );
    };
    local = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            id = lib.mkOption {
              example = 1;
              type = lib.types.int;
            };
            cidr.v4 = lib.mkOption {
              example = "192.168.2.1";
              type = lib.types.str;
            };
            cidr.v6 = lib.mkOption {
              example = "fd14:d122:ca4c::";
              default = null;
              type = lib.types.nullOr lib.types.str;
            };
            interface = lib.mkOption {
              example = "enp1s0";
              type = lib.types.str;
            };
            trusted = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Whether the netwrok should be trusted.
                Trusted networks can access all ports and hosts on the local network regardless of the firewall rules.
              '';
            };
            dhcp.v4 = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                Whether to run DHCPv4 server on the network.
              '';
            };
            dhcp.v6 = lib.mkOption {
              type = lib.types.bool;
              default = cfg.cidr.ipv6;
              description = ''
                Whether to run DHCPv6 server on the network.
              '';
            };
            reservations = lib.mkOption {
              type = lib.types.attrs;
              default = {};
              example = lib.literalExpression ''
                {
                  printer = { MACAddress = "ff:ff:ff:ff:ff:ff"; Address = "255.255.255.255"; };
                }
              '';
            };
          };
        }
      );
    };
  };
}

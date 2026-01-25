{
  config,
  lib,
  ...
}: let
  cfg = config.homelab;
in {
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    mounts.fast = lib.mkOption {
      default = "/fast";
      description = ''
        path to the 'fast' tier mount
      '';
    };
    mounts.slow = lib.mkOption {
      default = "/bulk";
      description = ''
        Path to the 'slow' tier mount
      '';
    };
    mounts.backups = lib.mkOption {
      default = "/backups";
      description = ''
        Path to the backups mount
      '';
    };

    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
    };
    baseDomain = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };
  };

  imports = [
    ./networks.nix
    ./samba.nix
    ./services
  ];

  config = lib.mkIf cfg.enable {
    users = {
      groups.${cfg.group} = {
        gid = 993;
      };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
      };
    };
  };
}

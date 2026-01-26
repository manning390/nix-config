{ config, lib, pkgs, vars, ...}:
let
  hl = config.homelab;
  cfg = hl.sambaClient;
in {
  options.homelab.sambaClient = {
    enable = lib.mkEnableOption "Enable Samba client mounts";

    shares = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
      options = {
        serverHost  = lib.mkOption { type = lib.types.str; };
        shareName   = lib.mkOption { type = lib.types.str; };
        mountPoint  = lib.mkOption { type = lib.types.path; };
        secret      = lib.mkOption {
            type = lib.types.str;
            description = "Sops.secrets key containing credentials for this share";
          };
      };
    }));
      default = {};
      description = "Samba shares to mount from the homelab";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cifs-utils ];
    
    # Declare sops secrets for all shares
    sops.secrets = lib.mkMerge (lib.mapAttrsToList (_name: share: {
      ${share.secret} = {};
    }) cfg.shares);
  };
}

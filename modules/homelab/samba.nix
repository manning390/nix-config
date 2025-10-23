{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  hl = config.homelab;
  cfg = hl.samba;
  ext = hl.networks.external;
  int = hl.networks.local;
  smb_networks =
    if ext ? config.networking.hostName then
    lib.lists.singleton "${ext.${config.networking.hostName}.gateway}/24"
  else
    lib.mapAttrsToList (_: val: "${val.cidr.v4}/24") (lib.attrsets.filterAttrs (n: v: v.trusted) int);
in {
  # Samba is the windows prefered networked storage protocol / server / mount
  options.homelab.samba = {
    enable = lib.mkEnableOption "Enables samba shares for the homelab";
    example = lib.mkOption {
      default =
        lib.attrsets.mapAttrs (
          name: value: name:
            value.settings
        )
        cfg.shares;
    };
    passwordFile = lib.mkOption {
      type = lib.types.path;
      default = /dev/null;
      description = "Path to samba password file";
    };
    globalSettings = lib.mkOption {
      description = "Global Samba parameters";
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        "browseable" = "yes";
        "writeable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
    commonSettings = lib.mkOption {
      description = "Parameters appl}d to each share";
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        "security" = "user";
        "invalid users" = ["root"];
      };
      apply = old:
        lib.attrsets.mergeAttrsList [
          {
            "preserve case" = "yes";
            "short preserve case" = "yes";
            "browseable" = "yes";
            "writable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
            "valid users" = hl.user;
            "fruit:appl" = "yes";
            "vfs objects" = "catia fruit streams_xattr";
          }
          old
        ];
    };
    shares = lib.mkOption {
      type = lib.types.attrs;
      example = lib.literalExpression ''
        CoolShare = {
          path = "/mnt/CoolShare";
          "fruit:appl" = "yes";
        };
      '';
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

    environment.systemPackages = [ config.services.samba.package ];

    systemd.tmpfiles.rules = map (x: "d ${x.path} 0775 ${hl.user} ${hl.group} - -") (lib.attrValues cfg.shares);

    sops.secrets."samba_password" = {}; # Make secret available
    # Make user for samba
    system.activationScripts.samba_user_create = ''
      smb_password=$(cat "${config.sops.secrets."samba_password".path}")
      echo -e "$smb_password\n$smb_password\n" | ${lib.getExe' pkgs.samba "smbpasswd"} -a -s ${hl.user}
    '';

    networking.firewall = {
      allowedTCPPorts = [ 5357 ];
      allowedUDPPorts = [ 3702 ];
    };

    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = lib.mkMerge [
          {
            workgroup = lib.mkDefault "WORKGROUP";
            "server string" = lib.mkDefault config.networking.hostName;
            "netbios name" = lib.mkDefault config.networking.hostName;
            "security" = lib.mkDefault "user";
            "invalid users" = ["root"];
            "hosts allow" = lib.mkDefault (lib.strings.concatStringsSep " " smb_networks);
            "guest account" = lib.mkDefault "nobody";
            "map to guest" = lib.mkDefault "bad user";
            "passdb backend" = lib.mkDefault "tdbsam";
          }
          cfg.globalSettings
        ];
      } // builtins.mapAttrs (name: value: value // cfg.commonSettings) cfg.shares;
    };
  };
}

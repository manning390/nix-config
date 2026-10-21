{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.backups;
in {
  options.homelab.backups = {
    enable = lib.mkEnableOption "scheduled encrypted homelab backups";

    # Destination and encryption credentials.
    repository = lib.mkOption {
      type = lib.types.str;
      default = "/backups/restic/${config.networking.hostName}";
      description = "Local Restic repository, outside all source datasets.";
    };
    backupMount = lib.mkOption {
      type = lib.types.str;
      default = "/backups";
      description = "Required destination mount.";
    };
    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/restic/homelab-password";
      description = "Runtime password file. Save an independent recovery copy.";
    };
    generatePassword = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Generate a password if missing. Disable when using a sops-managed passwordFile.";
    };

    # Schedule and storage efficiency.
    schedule = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 05:00:00";
    };
    compression = lib.mkOption {
      type = lib.types.enum ["auto" "max"];
      default = "auto";
    };
    retention = {
      daily = lib.mkOption {
        type = lib.types.ints.positive;
        default = 7;
      };
      weekly = lib.mkOption {
        type = lib.types.ints.positive;
        default = 4;
      };
      monthly = lib.mkOption {
        type = lib.types.ints.positive;
        default = 6;
      };
    };

    # Data selection and the writers that must pause for consistent snapshots.
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Restic exclusion patterns, matched against the snapshot paths.";
    };
    sources = lib.mkOption {
      default = {};
      description = "ZFS datasets to snapshot. Child datasets must be listed separately.";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          dataset = lib.mkOption {type = lib.types.str;};
          mountpoint = lib.mkOption {type = lib.types.str;};
          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [""];
            description = "Paths within the snapshot, starting with /; empty means the entire dataset.";
          };
        };
      });
    };
    quiesceServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      apply = lib.unique;
      example = ["immich-server.service" "postgresql.service"];
      description = ''
        Systemd service units whose writes must pause while ZFS snapshots are
        taken. To quiesce means to bring writers to a consistent, inactive
        state: the backup job stops active units, takes the snapshots, then
        restarts those units before Restic reads the snapshots. Inactive
        units are left inactive, and services are resumed if preparation fails.

        Enabled service modules should contribute their own units and local
        database dependencies to this list, using full names including
        .service. Nix merges contributions; duplicate units are removed so
        shared databases can be declared by multiple applications. Hosts may
        add additional writers here as needed.

        This setting only coordinates writers; it does not select data for
        backup. The application's data and database paths must also be covered
        by homelab.backups.sources. Units are stopped only when backups run.
      '';
    };

    # Copy completed local snapshots to an independently retained repository.
    remote = {
      enable = lib.mkEnableOption "copying completed local snapshots to an off-site repository";
      repository = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "sftp:backup@friend:/backups/glaciem";
      };
      passwordFile = lib.mkOption {
        type = lib.types.str;
        default = cfg.passwordFile;
      };
      schedule = lib.mkOption {
        type = lib.types.str;
        default = "*-*-* 06:00:00";
      };
      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Restic extended options, including sftp.command for a dedicated SSH identity and known_hosts file.";
      };
    };
  };
}

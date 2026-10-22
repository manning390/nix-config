{
  flake.aspects.homelab-backups = {
    description = "Encrypted, deduplicated homelab backups from consistent ZFS snapshots";

    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.homelab.backups;
      sources = lib.attrValues cfg.sources;
      snapshotName = "restic-homelab";
      snapshotRoot = source: "${lib.removeSuffix "/" source.mountpoint}/.zfs/snapshot/${snapshotName}";
      backupPaths = lib.concatMap (source: map (path: "${snapshotRoot source}${path}") source.paths) sources;

      scripts = import ./_scripts.nix {
        inherit cfg lib pkgs sources snapshotName;
      };

      retentionOptions = [
        "--keep-daily ${toString cfg.retention.daily}"
        "--keep-weekly ${toString cfg.retention.weekly}"
        "--keep-monthly ${toString cfg.retention.monthly}"
      ];
      timerFor = schedule: {
        OnCalendar = schedule;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
      backgroundIO = {
        Nice = 10;
        IOSchedulingClass = "idle";
      };
      remoteOptions = lib.concatMapStringsSep " " (option: "-o ${option}") cfg.remote.extraOptions;
      remoteCopyCommand = "${lib.getExe pkgs.restic} ${remoteOptions} copy --from-repo=${cfg.repository} --from-password-file=${cfg.passwordFile}";
    in {
      # The public settings live separately from job orchestration and shell hooks.
      imports = [./_options.nix];

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = sources != [];
            message = "homelab.backups.sources must specify ZFS source datasets.";
          }
          {
            assertion = !cfg.remote.enable || cfg.remote.repository != "";
            message = "Set homelab.backups.remote.repository.";
          }
          {
            assertion = lib.all (source: lib.all (path: path == "" || lib.hasPrefix "/" path) source.paths) sources;
            message = "homelab.backups.sources paths must be empty or start with /.";
          }
        ];

        systemd.tmpfiles.rules = ["d ${cfg.backupMount}/restic 0700 root root - -"];

        # Restic jobs: capture locally, verify stored data, and optionally copy off-site.
        services.restic.backups = {
          homelab = {
            inherit (cfg) repository passwordFile exclude;
            paths = backupPaths;
            initialize = true;
            extraBackupArgs = ["--compression=${cfg.compression}" "--tag=homelab"];
            pruneOpts = retentionOptions;
            runCheck = true;
            backupPrepareCommand = "${scripts.prepare}";
            backupCleanupCommand = "${scripts.cleanup}";
            timerConfig = timerFor cfg.schedule;
          };

          homelab-check = {
            inherit (cfg) repository passwordFile;
            createWrapper = false;
            runCheck = true;
            checkOpts = ["--read-data-subset=5%" "--retry-lock=1h"];
            timerConfig = timerFor "Sun *-*-* 12:00:00";
          };

          homelab-remote = lib.mkIf cfg.remote.enable {
            inherit (cfg.remote) repository passwordFile extraOptions;
            initialize = true;
            pruneOpts = retentionOptions;
            runCheck = true;
            timerConfig = timerFor cfg.remote.schedule;
          };
        };

        # Extend the generated Restic units with mount dependencies and resource priorities.
        systemd.services = {
          restic-backups-homelab = {
            requires = lib.optional cfg.generatePassword "homelab-backup-password.service";
            after = lib.optional cfg.generatePassword "homelab-backup-password.service";
            unitConfig.RequiresMountsFor = [cfg.backupMount] ++ map (source: source.mountpoint) sources;
            serviceConfig = backgroundIO // {UMask = "0077";};
          };

          restic-backups-homelab-check = {
            after = ["restic-backups-homelab.service"];
            unitConfig.RequiresMountsFor = [cfg.backupMount];
            serviceConfig = backgroundIO;
          };

          restic-backups-homelab-remote = lib.mkIf cfg.remote.enable {
            after = ["restic-backups-homelab.service"];
            unitConfig.RequiresMountsFor = [cfg.backupMount];
            serviceConfig =
              backgroundIO
              // {
                UMask = "0077";
                # Copy completed snapshots before the generated prune/check commands.
                ExecStart = lib.mkBefore [remoteCopyCommand];
              };
          };

          homelab-backup-password = lib.mkIf cfg.generatePassword {
            description = "Create the homelab backup encryption password once";
            serviceConfig = {
              Type = "oneshot";
              UMask = "0077";
            };
            script = scripts.password;
          };
        };
      };
    };
  };
}

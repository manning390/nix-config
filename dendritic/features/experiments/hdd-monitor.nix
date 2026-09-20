{
  flake.aspects = {aspects, ...}: {
    hdd-monitor = {
      description = "Monitor HDD access patterns to predict spindown behavior";

      nixos = {
        config,
        pkgs,
        lib,
        ...
      }: let
        cfg = config.services.hdd-monitor;
      in {
        options.services.hdd-monitor = {
          enable = lib.mkEnableOption "HDD access pattern monitoring";

          poolName = lib.mkOption {
            type = lib.types.str;
            default = "hdd-pool";
            description = "Name of the ZFS pool to monitor";
          };

          checkInterval = lib.mkOption {
            type = lib.types.str;
            default = "5min";
            description = "How often to check for activity (systemd time format: 1min, 5min, 10min, etc)";
          };
        };

        config = lib.mkIf cfg.enable {
          # Store the previous cumulative per-device operation counts.
          systemd.tmpfiles.rules = [
            "d /var/lib/hdd-monitor 0755 root root -"
          ];

          systemd.services.hdd-monitor = {
            description = "Check ${cfg.poolName} for activity";
            after = ["zfs-import.target"];

            # Systemd services do not inherit the interactive system profile.
            # Keep every external command used by the script in its runtime PATH.
            path = with pkgs; [coreutils gawk];

            serviceConfig = {
              Type = "oneshot";
              Nice = 19;
              IOSchedulingClass = "idle";
            };

            script = ''
              POOL="${cfg.poolName}"
              STATE_FILE="/var/lib/hdd-monitor/last_counters"

              # Check if pool exists
              if ! ${pkgs.zfs}/bin/zpool list "$POOL" >/dev/null 2>&1; then
                exit 0
              fi

              # zpool iostat with an interval is only a point-in-time sample;
              # it can miss activity between runs.  Instead, find this pool's
              # leaf devices and read their cumulative kernel counters.  Reading
              # /proc/diskstats does not itself wake a sleeping disk.
              DEVICES=$(${pkgs.zfs}/bin/zpool status -P "$POOL" | awk '$1 ~ /^\/dev\// { print $1 }')
              if [ -z "$DEVICES" ]; then
                echo "ERROR no leaf devices found for pool=$POOL"
                exit 1
              fi

              READ_OPS=0
              WRITE_OPS=0
              for DEVICE in $DEVICES; do
                DEVICE_NAME=$(basename "$(readlink -f "$DEVICE")")
                COUNTERS=$(awk -v device="$DEVICE_NAME" '$3 == device { print $4, $8; exit }' /proc/diskstats)
                if [ -z "$COUNTERS" ]; then
                  echo "ERROR no diskstats entry for device=$DEVICE_NAME"
                  exit 1
                fi
                set -- $COUNTERS
                READ_OPS=$((READ_OPS + $1))
                WRITE_OPS=$((WRITE_OPS + $2))
              done

              if [ ! -f "$STATE_FILE" ]; then
                echo "$READ_OPS $WRITE_OPS" > "$STATE_FILE"
                echo "SAMPLE read_ops=$READ_OPS write_ops=$WRITE_OPS baseline=1"
                exit 0
              fi

              read -r PREV_READ PREV_WRITE < "$STATE_FILE"
              # Counters reset after a reboot, so establish a fresh baseline.
              if [ "$READ_OPS" -lt "$PREV_READ" ] || [ "$WRITE_OPS" -lt "$PREV_WRITE" ]; then
                echo "$READ_OPS $WRITE_OPS" > "$STATE_FILE"
                echo "SAMPLE read_ops=$READ_OPS write_ops=$WRITE_OPS baseline=1"
                exit 0
              fi

              READ_DELTA=$((READ_OPS - PREV_READ))
              WRITE_DELTA=$((WRITE_OPS - PREV_WRITE))
              TOTAL_DELTA=$((READ_DELTA + WRITE_DELTA))
              echo "$READ_OPS $WRITE_OPS" > "$STATE_FILE"
              echo "SAMPLE read_ops=$READ_OPS write_ops=$WRITE_OPS read_delta=$READ_DELTA write_delta=$WRITE_DELTA total_delta=$TOTAL_DELTA"

              if [ "$TOTAL_DELTA" -gt 0 ]; then
                echo "ACCESS read_ops=$READ_DELTA write_ops=$WRITE_DELTA total_ops=$TOTAL_DELTA"
              fi
            '';
          };

          # Timer to run the check periodically
          systemd.timers.hdd-monitor = {
            wantedBy = ["timers.target"];
            timerConfig = {
              OnBootSec = "1min";
              OnUnitActiveSec = cfg.checkInterval;
              Unit = "hdd-monitor.service";
            };
          };

          environment.systemPackages = [
            (pkgs.writeShellScriptBin "hdd-stats" ''
              echo "=== HDD Access Pattern Analysis ==="
              echo ""

              # Count access events
              TOTAL=$(journalctl -u hdd-monitor.service --since "24 hours ago" | grep -c "ACCESS" || echo 0)
              echo "Access events in last 24h: $TOTAL"

              if [ "$TOTAL" -lt 2 ]; then
                echo "Not enough data. Wait 24 hours."
                exit 0
              fi

              echo ""
              echo "=== Predicted Spin-ups (last 24h) ==="

              # For each timeout, count gaps longer than timeout
              for TIMEOUT in 5 10 15 30 60; do
                SPINUPS=$(journalctl -u hdd-monitor.service --since "24 hours ago" --output=short-unix | \
                  grep "ACCESS" | \
                  awk -v timeout=$((TIMEOUT * 60)) '
                    {
                      if (last > 0 && ($1 - last) > timeout) spinups++
                      last = $1
                    }
                    END { print spinups + 0 }
                  ')
                echo "  $TIMEOUT min timeout: $SPINUPS spin-ups/day"
              done

              echo ""
              echo "=== Recent Activity ==="
              journalctl -u hdd-monitor.service -n 20 --no-pager | grep "ACCESS"
            '')
          ];

          environment.shellAliases = {
            hdd-watch = "journalctl -u hdd-monitor.service -f";
          };
        };
      };
    };
  };
}

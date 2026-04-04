{
  flake.aspects = {aspects, ...}: {
    hdd-monitor = {
      description = "Monitor HDD access patterns to predict spindown behavior";

      nixos = {config, pkgs, lib, ...}: let
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
          # Store last operation count
          systemd.tmpfiles.rules = [
            "d /var/lib/hdd-monitor 0755 root root -"
          ];

          systemd.services.hdd-monitor = {
            description = "Check ${cfg.poolName} for activity";
            after = ["zfs-import.target"];
            
            serviceConfig = {
              Type = "oneshot";
              Nice = 19;
              IOSchedulingClass = "idle";
            };

            script = ''
              POOL="${cfg.poolName}"
              STATE_FILE="/var/lib/hdd-monitor/last_ops"
              
              # Check if pool exists
              if ! ${pkgs.zfs}/bin/zpool list "$POOL" >/dev/null 2>&1; then
                exit 0
              fi
              
              # Get total operations (read + write)
              STATS=$(${pkgs.zfs}/bin/zpool iostat -Hp "$POOL" 1 1 | tail -1)
              READ=$(echo "$STATS" | awk '{print $4}')
              WRITE=$(echo "$STATS" | awk '{print $5}')
              TOTAL=$((READ + WRITE))
              
              # Read previous value
              if [ -f "$STATE_FILE" ]; then
                PREV_OPS=$(cat "$STATE_FILE")
              else
                PREV_OPS=0
              fi
              
              # Log if there was activity
              if [ "$TOTAL" -gt "$PREV_OPS" ]; then
                DELTA=$((TOTAL - PREV_OPS))
                echo "ACCESS $DELTA"
              fi
              
              # Save current value
              echo "$TOTAL" > "$STATE_FILE"
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

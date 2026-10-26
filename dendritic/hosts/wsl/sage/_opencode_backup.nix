# home-manager class; imported only by sage.
{
  config,
  lib,
  pkgs,
  ...
}: let
  backup = pkgs.writeShellApplication {
    name = "opencode-backup";
    runtimeInputs = [pkgs.python3];
    text = ''
      exec python3 ${./_opencode_backup.py} \
        ${lib.escapeShellArg "${config.xdg.dataHome}/opencode"} \
        ${lib.escapeShellArg "${config.home.homeDirectory}/Backups/opencode"}
    '';
  };
in {
  systemd.user.services.opencode-backup = {
    Unit.Description = "Back up OpenCode sessions and contexts";
    Service = {
      Type = "oneshot";
      ExecStart = "${backup}/bin/opencode-backup";
      UMask = "0077";
      TimeoutStartSec = "10min";
    };
  };

  systemd.user.timers.opencode-backup = {
    Unit.Description = "Back up OpenCode every weekday at 4pm";
    Timer = {
      OnCalendar = "Mon..Fri *-*-* 16:00:00";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };
}

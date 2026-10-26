# OpenCode backups on Sage

Sage's Home Manager configuration installs `opencode-backup.service` and a user
timer that runs Monday–Friday at **16:00 in the system's local timezone**.
The persistent timer catches up on a missed run when the user manager next starts
(for example, after starting WSL).

Backups are dated directories under `/home/pch/Backups/opencode`. Each contains
OpenCode's data from the configured XDG data directory (normally
`/home/pch/.local/share/opencode`), excluding logs. The SQLite database is copied
using SQLite's online backup API, including committed data still in its WAL.
Older file-based session storage is copied too. Incomplete snapshots are not
published, and existing snapshots are never overwritten or automatically pruned.

The backup directory is private to the user. Treat its contents as sensitive:
they can include conversation contents and credentials. This is a local safeguard
against lost sessions, not protection against disk failure.

After applying Sage's configuration with `nh os switch .`, inspect or manually
run the backup:

```sh
systemctl --user list-timers opencode-backup.timer
systemctl --user start opencode-backup.service
journalctl --user -u opencode-backup.service
```

To restore, stop OpenCode's clients and background service first. Preserve the
current data directory by moving it aside, then copy a chosen snapshot to the
original data directory. Do not merge a backup database with existing `-wal` or
`-shm` files. Start OpenCode again once the restore is complete.

This backs up the standard data directory; a custom `OPENCODE_DB` location outside
that directory is not covered. Review disk usage periodically and remove old
snapshots manually as needed.

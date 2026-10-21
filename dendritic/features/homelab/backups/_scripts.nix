{
  cfg,
  lib,
  pkgs,
  sources,
  snapshotName,
}: let
  runtime = "/run/restic-backups-homelab";
  snapshots = map (source: "${source.dataset}@${snapshotName}") sources;

  # Preparation and cleanup both resume exactly the units recorded before stopping.
  resumeServices = pkgs.writeShellScript "homelab-backup-resume" ''
    set -euo pipefail
    if [ -s ${runtime}/stopped-services ]; then
      mapfile -t units < ${runtime}/stopped-services
      ${pkgs.systemd}/bin/systemctl start "''${units[@]}"
      rm -f ${runtime}/stopped-services
    fi
  '';

  verifySourceMounts =
    lib.concatMapStringsSep "\n" (source: ''
      test "$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE --target ${lib.escapeShellArg source.mountpoint})" = ${lib.escapeShellArg source.dataset}
    '')
    sources;

  removeSnapshots =
    lib.concatMapStringsSep "\n" (name: ''
      if ${pkgs.zfs}/bin/zfs list -H -t snapshot ${lib.escapeShellArg name} >/dev/null 2>&1; then
        ${pkgs.zfs}/bin/zfs destroy ${lib.escapeShellArg name}
      fi
    '')
    snapshots;
in {
  # Stop writers only for snapshot creation, not for the lengthy Restic upload.
  prepare = pkgs.writeShellScript "homelab-backup-snapshot" ''
    set -euo pipefail
    test -s ${lib.escapeShellArg cfg.passwordFile}
    ${verifySourceMounts}

    # Resume after an interrupted previous preparation before starting anew.
    ${resumeServices}
    # Escape the trap command in Nix to avoid an empty Tree-sitter Bash injection.
    trap ${lib.escapeShellArg (toString resumeServices)} EXIT

    for unit in ${lib.escapeShellArgs cfg.quiesceServices}; do
      if ${pkgs.systemd}/bin/systemctl is-active --quiet "$unit"; then
        printf '%s\n' "$unit" >> ${runtime}/stopped-services
      fi
    done
    if [ -s ${runtime}/stopped-services ]; then
      mapfile -t units < ${runtime}/stopped-services
      ${pkgs.systemd}/bin/systemctl stop "''${units[@]}"
    fi

    ${removeSnapshots}
    ${pkgs.zfs}/bin/zfs snapshot ${lib.escapeShellArgs snapshots}
  '';

  # Restic's post-stop hook runs this on both success and failure.
  cleanup = pkgs.writeShellScript "homelab-backup-cleanup" ''
    set -euo pipefail
    ${resumeServices}
    ${removeSnapshots}
  '';

  # Used only when the host opts into generation instead of supplying a secret.
  password = ''
    set -euo pipefail
    password=${lib.escapeShellArg cfg.passwordFile}
    if [ ! -e "$password" ]; then
      install -d -m 0700 "$(dirname "$password")"
      tmp=$(mktemp "$(dirname "$password")/.restic-password.XXXXXX")
      trap 'rm -f "$tmp"' EXIT
      ${pkgs.openssl}/bin/openssl rand -base64 48 > "$tmp"
      # Never overwrite an existing repository's password.
      ln "$tmp" "$password"
    fi
    test -s "$password"
  '';
}

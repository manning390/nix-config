# Ruby / Sentry NVMe swap

Swap **Sentry's Samsung 970 EVO 1 TB (non-Plus)** with **Ruby's Samsung 980 PRO 2 TB**.
Sentry keeps its Samsung 970 EVO Plus 1 TB.

This runbook backs up both hosts to Glaciem, reinstalls each onto its incoming
drive, then restores host-specific state. It deliberately leaves **Glaciem
troubleshooting and new Impermanence/root-reset behavior out of scope**.

**Read the whole guide first. Commands containing `REPLACE_...` are templates:
replace them with verified values. Never guess a disk, partition, or UUID.**
Commands in installer sections run as root in Bash unless stated otherwise.

## 1. Record the current layout — on each installed host

The inventory in [hosts.md](hosts.md) records models, not which partitions belong
to each drive. `/dev/nvme0n1` is not a stable identity.

Run on Ruby, then Sentry:

```sh
HOST=$(hostname)
OUT="$HOME/drive-swap-$HOST"
mkdir -p "$OUT"
lsblk -e7 -o NAME,PATH,SIZE,MODEL,SERIAL,FSTYPE,FSAVAIL,FSUSE%,MOUNTPOINTS,UUID | tee "$OUT/lsblk.txt"
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS | tee "$OUT/findmnt.txt"
df -hT -x tmpfs -x devtmpfs | tee "$OUT/df.txt"
ls -l /dev/disk/by-id/ | tee "$OUT/disk-by-id.txt"
sudo blkid | tee "$OUT/blkid.txt"
id | tee "$OUT/user-id.txt"
sudo du -xsh /home /root /etc /var/lib /var/log
```

Record this worksheet somewhere accessible from another computer:

| Item | Verified value |
| --- | --- |
| Ruby 980 PRO serial and whole-disk by-id path | |
| Sentry non-Plus 970 EVO serial and whole-disk by-id path | |
| Sentry retained 970 EVO Plus serial and by-id path | |
| Ruby old root, home, and boot UUIDs | |
| Sentry old root, home, boot, and swap UUIDs | |
| Additional local data partitions and mountpoints | |
| Glaciem IP address and SSH fingerprint | |
| Ruby and Sentry user numeric UID/GID | |

Check drive health on both machines:

```sh
nix shell nixpkgs#smartmontools
sudo smartctl -x /dev/disk/by-id/REPLACE_WHOLE_DISK_ID
```

Run this for all three drives. Investigate critical warnings, media errors, or
unexpected wear before proceeding. Check that Ruby's data **and rebuilt Nix
store** fit comfortably on the incoming 1 TB drive. Check Sentry's data fits its
planned destinations; do not assume two drives automatically form one filesystem.

Identify local data outside `/home`, including game libraries, VMs, containers,
and development databases. Steam Cloud does not guarantee all saves are covered.
Proton prefixes and local saves can matter even when game downloads are replaceable.
Do not clean up game libraries until you know where their saves live.

**Stop:** if the outgoing Sentry drive contains only data, reinstalling Sentry
may be unnecessary. This guide intentionally uses a fresh installation on each
incoming drive for a consistent procedure. Choose that approach before proceeding.

## 2. Prepare Glaciem and independent recovery access

On Glaciem:

```sh
findmnt /backups
df -hT /backups
sudo zpool status
sudo zfs list -o name,used,avail,mountpoint
```

Confirm `/backups` is the intended mounted dataset, the pools are healthy, and
there is enough free space for both hosts plus overhead. Do not accidentally
write backups into an unmounted `/backups` directory on root.

Create repositories separate from Glaciem's own managed Restic repository:

```sh
sudo install -d -m 0700 -o pch -g "$(id -gn pch)" /backups/drive-swap
sudo install -d -m 0700 -o pch -g "$(id -gn pch)" /backups/drive-swap/ruby
sudo install -d -m 0700 -o pch -g "$(id -gn pch)" /backups/drive-swap/sentry
```

Use a strong Restic password saved in a password manager accessible from another
device. It must not exist only inside the backups or on the two drives being
swapped. This guide lets Restic prompt rather than putting passwords into shell
history or the Nix store.

Keep another independent copy of irreplaceable documents. The migration
repositories are on Glaciem's HDD; do not assume its normal backup job copies
these repositories off-site.

Arrange SSH access from a **third trusted computer** whose agent can authenticate
to Glaciem and fetch `nix-private`. For example, Mado is already authorized for
Glaciem in this repository. Verify the actual keys and access, not just the config:

```sh
ssh-add -l
ssh pch@REPLACE_GLACIEM_IP 'id; df -h /backups'
```

Alternatively, use a dedicated temporary recovery key authorized on Glaciem.
Do not rely on a private key that will disappear when the target drive is erased.

## 3. Prepare installation configurations — before taking machines apart

Current repository state:

- Ruby has `_disk-config.nix`, but its host does not import it.
- Sentry has no Disko recipe.
- Both active `hardware.nix` files contain old filesystem UUIDs.

Recommended scope: use Disko-generated native NixOS mounts, with **no new
Impermanence configuration in this migration**.

### Target layout used by this guide

On each incoming drive:

| Partition | Size | Mount |
| --- | --- | --- |
| EFI system partition | 1 GiB | `/boot` |
| ext4 | Remaining space | `/`, including `/home` and `/nix` |

This avoids fixed-size root/store partitions filling independently. It is not an
ephemeral-root layout. Impermanence can be designed separately later.

Sentry's retained Plus drive is **not a Disko formatting target**. Preserve it
unchanged. Its existing data can be mounted after installation at an appropriate
non-conflicting path, such as `/games` or `/data`.

### Edit the repository

Create or replace each host's `_disk-config.nix` with this template, using that
host's **incoming** drive's serial-based ID:

```nix
{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko];

  disko.devices.disk.system = {
    type = "disk";
    device = "/dev/disk/by-id/REPLACE_INCOMING_WHOLE_DISK_ID";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
```

- Ruby's incoming ID must identify the **970 EVO non-Plus**.
- Sentry's incoming ID must identify the **980 PRO**.
- Import `./_disk-config.nix` from the host's **`nixos` module** in `default.nix`.
  Ruby already has an `imports` list for Framework hardware; extend that list
  rather than declaring `imports` twice.
- Remove the replaced `fileSystems` and old `swapDevices` entries from both
  `hardware.nix` files. Preserve the other hardware settings.
- Remove or set Sentry's `local.sops.homeOnSeparatePartition` to `false`: the
  layout above does not have a separate `/home`.
- Decide whether to enable `zramSwap.enable = true` for memory pressure.
  This is not disk swap and does not provide hibernation. Ruby already disables
  hibernation; do not enable it as part of this procedure.

Do **not** apply these incoming-drive configurations to the old running systems.
Build them without switching:

```sh
git status --short
# Stage the specific new files so the Git-backed flake can see them.
git add dendritic/hosts/nixos/ruby/_disk-config.nix dendritic/hosts/nixos/sentry/_disk-config.nix
nix eval --json .#nixosConfigurations.ruby.config.disko.devices.disk
nix eval --json .#nixosConfigurations.sentry.config.disko.devices.disk
nix eval --json .#nixosConfigurations.ruby.config.fileSystems
nix eval --json .#nixosConfigurations.sentry.config.fileSystems
nix build .#nixosConfigurations.ruby.config.system.build.toplevel --out-link result-ruby
nix build .#nixosConfigurations.sentry.config.system.build.toplevel --out-link result-sentry
```

Review `git diff` and `git diff --cached`. Verify each host targets exactly one
incoming drive and has no old root/home/nix/swap UUID references. Make the reviewed
changes available from the installer: commit and push them to a migration branch,
or securely transfer the complete working tree, including staged/untracked files.
Record the exact revision. Do not update `flake.lock` during the migration.

## 4. Build and boot-test installer media

See [Host setup](new-host-playbook.md) for USB imaging instructions.

```sh
just build-iso ruby
```

Flash or save `result/iso/*.iso` before another build replaces the `result` link.
One tested installer can install both hosts; separate Ruby/Sentry images are not
required. Building an ISO does not by itself guarantee offline installation,
private-input access, or embedded recovery keys.

Boot-test it on both machines **before the final backups**:

1. Boot in UEFI mode.
2. Connect networking (use `nmtui` if available, or Ethernet).
3. Record the installer's IP with `ip -br address`.
4. Start SSH if needed with `sudo systemctl start sshd`.
5. Confirm you can reach Glaciem and access the migration checkout/private inputs.

The commands below assume remote operation from the trusted third computer.
Set an installer login password locally with `passwd` if required by that ISO's
SSH policy, or install an authorized key. Do not enable root password SSH.

From the trusted computer:

```sh
ssh -A nixos@REPLACE_INSTALLER_IP
```

In that installer session:

```sh
sudo --preserve-env=SSH_AUTH_SOCK bash
export NIX_CONFIG='experimental-features = nix-command flakes'
nix shell nixpkgs#restic nixpkgs#rsync nixpkgs#git nixpkgs#smartmontools
set -euo pipefail
test -d /sys/firmware/efi
ssh-add -l
ssh pch@REPLACE_GLACIEM_IP 'id; test -d /backups/drive-swap'
```

`nix shell` starts another shell; subsequent commands run inside it. Install
additional filesystem tools if your inspected source layout needs them.
Forward an agent only to an installer you trust; disconnect when finished.
Verify Glaciem's SSH fingerprint against a previously trusted record.

Clone the prepared configuration **outside `/mnt`**:

```sh
git clone --branch REPLACE_MIGRATION_BRANCH https://github.com/manning390/nix-config /root/nix-config
cd /root/nix-config
git rev-parse HEAD
```

If using a transferred checkout, substitute its location. Confirm the revision
matches the reviewed configuration. Test a host build from the installer; this
also exercises private-input authentication:

```sh
HOST=ruby
nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" --out-link "/root/result-$HOST"
```

Repeat for Sentry as appropriate. Resolve access/evaluation failures **before
erasing anything**. Never copy private keys into the repository or Nix store.

## 5. Final offline backups — repeat for each host before swapping

Shut down the installed OS cleanly and boot the installer. Do not resume normal
use afterward: changes would not be in the final backup.

Use the installer SSH/root/tool setup above. Set these explicitly for the machine
being backed up; the installer's own hostname is not authoritative:

```sh
HOST=ruby
GLACIEM=REPLACE_GLACIEM_IP
export RESTIC_REPOSITORY="sftp:pch@$GLACIEM:/backups/drive-swap/$HOST"
```

Use `HOST=sentry` on Sentry. Environment variables do not survive a reboot or a
new SSH session; set them again whenever needed.

### Mount source filesystems read-only

Use the UUIDs recorded in section 1:

```sh
mkdir -p /mnt/source
mount -o ro /dev/disk/by-uuid/REPLACE_OLD_ROOT_UUID /mnt/source
mount -o ro /dev/disk/by-uuid/REPLACE_OLD_HOME_UUID /mnt/source/home
findmnt -R /mnt/source
```

These commands match the currently declared separate ext4 root/home layouts.
If inspection shows a different layout, adapt the mounts before continuing.
Do not mount `/nix` or `/boot`: this backup excludes their contents and rebuilds
them. Capture their partition information in the worksheet instead.

For additional local data, mount it read-only under its original path within
`/mnt/source`, then add that mountpoint as another explicit backup source below.
Never mount Samba/NFS shares in this source tree.

Verify actual documents and saves are visible:

```sh
ls -la /mnt/source/home
ls -la /mnt/source/etc/ssh
ls -la /mnt/source/var/lib/sops-nix
```

Keep these paths and their ownership/permissions with their **logical host**:

- All user homes, including hidden files and user SSH keys.
- `/etc/ssh/host_ruby_ed25519_key*` or `host_sentry_ed25519_key*` (custom SOPS identities).
- Ordinary `/etc/ssh/ssh_host_*` server identities.
- `/var/lib/sops-nix`, including `key.txt` if present.
- `/etc/machine-id`.
- Relevant NetworkManager profiles and persistent application/service state.
- `/root`, local configuration checkouts, and all extra local data.

Do not print private key contents into logs.

### Create and verify the backup

Initialize each **new, empty** repository once:

```sh
restic init
```

If a repository already exists, use its existing password and run `restic
snapshots` instead. Do not initialize over or replace an existing repository.

Back up root and home explicitly. `--one-file-system` prevents accidental traversal
of other mounts; each extra mounted data filesystem therefore needs its own source
argument:

```sh
restic backup \
  --host "$HOST" --tag drive-swap-final --one-file-system \
  --exclude /mnt/source/nix \
  --exclude /mnt/source/boot \
  --exclude /mnt/source/dev \
  --exclude /mnt/source/proc \
  --exclude /mnt/source/sys \
  --exclude /mnt/source/run \
  --exclude /mnt/source/tmp \
  /mnt/source /mnt/source/home
restic snapshots
restic check --read-data
```

Do not accept an incomplete backup, unreadable-file warning, or failed integrity
check. Record the **exact final snapshot ID** for this host:

```sh
SNAP=REPLACE_FINAL_SNAPSHOT_ID
restic ls "$SNAP" /mnt/source/home
restic ls "$SNAP" /mnt/source/etc/ssh
restic ls "$SNAP" /mnt/source/var/lib/sops-nix
```

Test an actual restore of a small document directory:

```sh
mkdir -p /root/restore-test
restic restore "$SNAP:/mnt/source/home/REPLACE_USER/REPLACE_SMALL_DOCUMENT_DIRECTORY" \
  --target /root/restore-test --verify
diff -r /mnt/source/home/REPLACE_USER/REPLACE_SMALL_DOCUMENT_DIRECTORY /root/restore-test
```

This test directory is on the live system; choose a small one that fits RAM.
Verify some documents can actually be opened. Confirm hidden files, saves, and
extra data mounts exist in the snapshot too.

**Hard stop before hardware exchange:**

- Both final snapshot IDs and passwords are independently accessible.
- Both backups pass a full read check and a test restore.
- Irreplaceable documents have a second independent copy.
- Both machines remain shut down after the final backups.
- The reviewed migration checkout is accessible without either original OS.

## 6. Exchange the hardware

1. Power off both machines completely; disconnect power and peripherals.
2. Follow the Framework service instructions for battery disconnection/firmware
   battery-disable and SSD replacement. Take appropriate ESD precautions.
3. Label the SSDs by model **and serial**, and photograph their original positions.
4. Remove Sentry's **970 EVO non-Plus**, leaving the Plus installed.
5. Move Ruby's **980 PRO 2 TB** into that Sentry slot.
6. Install the **970 EVO non-Plus 1 TB** in Ruby.
7. Reassemble before applying power.

Optionally disconnect Sentry's retained Plus drive during installation if
practical. This reduces accidental-formatting risk, but is not required.
Do not erase its partitions to make the new layout match.

## 7. Provision and install — one host at a time

Boot the installer in UEFI mode and repeat the root shell, tool setup, agent
forwarding, and checkout setup from section 4.

Set the correct host and backup snapshot:

```sh
HOST=ruby
GLACIEM=REPLACE_GLACIEM_IP
SNAP=REPLACE_RUBY_FINAL_SNAPSHOT_ID
export RESTIC_REPOSITORY="sftp:pch@$GLACIEM:/backups/drive-swap/$HOST"
cd /root/nix-config
lsblk -e7 -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
nix eval --json ".#nixosConfigurations.$HOST.config.disko.devices.disk"
restic snapshots
restic ls "$SNAP" /mnt/source/etc/ssh
```

For Sentry use `HOST=sentry` and its own snapshot ID. Ruby must target the
non-Plus 970 EVO; Sentry must target the 980 PRO. Match serials to the worksheet.
Never restore Ruby's identities onto Sentry or vice versa.

Build once more before destructive provisioning:

```sh
nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" --out-link "/root/result-$HOST"
```

### Destructive checkpoint

**The next command destroys the incoming drive's existing contents.** At this
point those contents belong to the *other* host. Its verified backup is therefore
essential. Confirm neither machine's backup is missing.

Confirm no source/target disk is mounted:

```sh
findmnt -R /mnt
lsblk -e7 -o NAME,SIZE,MODEL,SERIAL,MOUNTPOINTS
```

If anything from the target drive is mounted, unmount those verified mountpoints
first. Do not run broad unmount commands blindly.

Use the Disko version pinned by this checkout:

```sh
DISKO_SRC=$(nix eval --impure --raw --expr '(builtins.getFlake (toString ./.)).inputs.disko.outPath')
nix run "$DISKO_SRC" -- \
  --mode destroy,format,mount \
  --flake "/root/nix-config#nixosConfigurations.$HOST"
```

Inspect the result before copying anything:

```sh
findmnt -R /mnt
lsblk -f
df -hT /mnt /mnt/boot
```

The new root and EFI filesystems must be on the intended incoming drive.
The retained Plus must be unchanged.

### Restore homes and identities before activation

```sh
mkdir -p /mnt/home /mnt/etc /mnt/root/recovery-reference
chmod 0700 /mnt/root /mnt/root/recovery-reference
restic restore "$SNAP:/mnt/source/home" --target /mnt/home --verify
restic restore "$SNAP:/mnt/source/etc" --target /mnt/root/recovery-reference/etc --verify
restic restore "$SNAP:/mnt/source/root" --target /mnt/root/recovery-reference/root --verify
restic restore "$SNAP:/mnt/source/var/lib" --target /mnt/root/recovery-reference/var-lib --verify
```

This preserves the full old configuration/state for selective recovery without
overwriting the new OS wholesale. Allow disk space for this reference copy;
move large unneeded application datasets to a separate recovery disk if necessary.
Do not also restore the entire old root.

Restore identities:

```sh
mkdir -p /mnt/etc/ssh /mnt/var/lib
cp -a /mnt/root/recovery-reference/etc/ssh/. /mnt/etc/ssh/
cp -a /mnt/root/recovery-reference/etc/machine-id /mnt/etc/machine-id
if test -d /mnt/root/recovery-reference/var-lib/sops-nix; then
  cp -a /mnt/root/recovery-reference/var-lib/sops-nix /mnt/var/lib/
fi
test -s "/mnt/etc/ssh/host_${HOST}_ed25519_key"
stat -c '%a %u:%g %n' "/mnt/etc/ssh/host_${HOST}_ed25519_key"
```

Private host keys should remain root-owned and inaccessible to other users
(normally mode `600`). Investigate missing SOPS identities before installation.
Do not generate replacement identities unless deliberately re-encrypting secrets.

If NetworkManager profiles existed and are needed, restore them:

```sh
if test -d /mnt/root/recovery-reference/etc/NetworkManager/system-connections; then
  mkdir -p /mnt/etc/NetworkManager/system-connections
  cp -a /mnt/root/recovery-reference/etc/NetworkManager/system-connections/. \
    /mnt/etc/NetworkManager/system-connections/
fi
```

Compare `/var/lib` recovery state with the services you actually use. Restore
needed directories before first boot, for example Bluetooth pairings or local
databases, **only when the service and ownership match**. For a selected directory:

```sh
# Template: replace the directory name after reviewing its contents.
cp -a /mnt/root/recovery-reference/var-lib/REPLACE_SERVICE_DIRECTORY /mnt/var/lib/
```

Do not blindly copy all of old `/etc`, `/var/lib`, `/root`, or `/var/lib/nixos`
over the fresh installation. Restore root-owned credentials/work selectively;
do not overwrite Nix's new installation bookkeeping.

Restore any extra data filesystem from its recorded snapshot path to its chosen
destination with the same `restic restore SNAP:/path --target DEST --verify`
pattern. Check that destination storage is mounted first.

### Install

```sh
mkdir -p /mnt/etc/nixos
rsync -a /root/nix-config/ /mnt/etc/nixos/
nixos-install --flake "/mnt/etc/nixos#$HOST"
```

Confirm installation finishes successfully and sets up the EFI bootloader. Set a
root recovery password if prompted. Check user-home ownership against the
numeric UID/GID worksheet:

```sh
ls -ldn /mnt/home/*
test -s "/mnt/etc/ssh/host_${HOST}_ed25519_key"
sync
```

If an error occurs, **do not rerun destructive Disko provisioning**. Fix access,
mounts, or configuration and rerun only the failed non-destructive step.

Reboot and remove the USB:

```sh
reboot
```

## 8. Validate each installed host

On the installed system:

```sh
hostname
lsblk -e7 -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS,UUID
findmnt --target /
findmnt --target /boot
df -hT / /home /nix
systemctl --failed
sudo journalctl -b -p err --no-pager
sudo test -s "/etc/ssh/host_$(hostname)_ed25519_key"
sudo test -d /run/secrets
ssh pch@REPLACE_GLACIEM_IP 'hostname'
```

`/home` and `/nix` should now live inside root, not separate filesystems.
Verify required SOPS-managed services and files actually work; the existence of
`/run/secrets` alone is not proof all secrets decrypted.

Check:

- Normal user login, sudo, desktop, display configuration, sound, and networking.
- Documents, browser profiles, password manager, SSH/Git access, and development work.
- Ruby Wi-Fi, battery behavior, and suspend/resume.
- Sentry GPU acceleration, Steam libraries, game launches, saves, and Proton prefixes.
- No unexpected SSH host-key change from the trusted third computer.
- No old UUIDs are still referenced by the active mount/swap configuration.

Reboot once more and repeat the mount/service checks.

### Reconnect and mount Sentry's retained Plus drive

If disconnected, power down before reconnecting it. Inspect before making changes:

```sh
lsblk -f
sudo blkid
```

Its existing filesystems may contain an old root or home rather than an empty
games partition. Mount the relevant partition read-only to inspect it first:

```sh
sudo mkdir -p /mnt/retained-check
sudo mount -o ro /dev/disk/by-uuid/REPLACE_RETAINED_DATA_UUID /mnt/retained-check
ls -la /mnt/retained-check
sudo umount /mnt/retained-check
```

Once you know which partition contains the intended data, add an ordinary
NixOS mount declaration to Sentry's configuration, for example:

```nix
fileSystems."/games" = {
  device = "/dev/disk/by-uuid/REPLACE_RETAINED_DATA_UUID";
  fsType = "ext4"; # Use the verified existing filesystem type.
};
```

This declaration does not format it. Do not add that disk to a destructive
Disko recipe merely to mount its existing filesystem. Review permissions using
the original numeric IDs; do not recursively `chown` an entire old system disk.

Build and apply from the reviewed checkout:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#sentry
findmnt /games
```

Point Steam at the actual restored library directory, not just the mountpoint.
Reclaiming old partitions on this retained drive is a **separate destructive
operation** requiring its own verified backup and plan.

## 9. Finish and retain recovery options

- Update the normal configuration checkout with any installation-time fixes.
- On each host run `just document-host` from that checkout and review the updated
  [inventory](hosts.md).
- Establish regular backups for both desktops; these one-time repositories are
  not automatically scheduled client backups.
- Keep both final snapshots and the recovery reference directories until both
  systems have been used successfully, including several reboots and game/save tests.
- Remove temporary installer SSH credentials/authorized keys and disconnect
  forwarded agents when finished.
- Do not prune migration backups until an independent newer backup is verified.

After either incoming disk is formatted, swapping hardware back is **not**
rollback: its old installation has been erased. Recovery is reinstalling the
appropriate host and restoring its recorded backup.

Investigate Glaciem's ZFS boot/mount behavior and possible root-reset mechanism
separately, as tracked in the README.

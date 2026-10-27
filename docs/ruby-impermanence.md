# Ruby: root-only impermanence

Ruby boots with a 4 GiB tmpfs root. Its existing `/home` and `/nix` partitions
remain persistent; system state lives in `/nix/persist`. The old ext4 root is
left untouched for recovery. No repartitioning or formatting is required.

Persisted state includes all of `/etc`, `/var/lib`, and `/var/log`. This covers
`/etc/machine-id`, all SSH keys in `/etc/ssh`, mutable account databases
(including password hashes), NetworkManager connections, and `/etc/nixos`.
Home is not made ephemeral. `/etc` is bind-mounted during the initrd, before
account activation and stage-2 systemd. Persisting the directory rather than
individual account files allows NixOS and password tools to replace them
atomically. Nix still manages its declared configuration, but manual additions
under `/etc` also survive: this is deliberately not a fully ephemeral `/etc`.
`/var/lib` is deliberately broad: this migration does not attempt to discard
individual services' state. `/var/cache`, `/tmp`, `/root`, and other unlisted
root paths are ephemeral. Move anything valuable there before proceeding.

SOPS uses `host_ruby_ed25519_key` (not the machine ID) and optionally its age
key. Both keys are preserved, and SOPS reads their backing paths directly.
Automatic decryption-key generation is disabled to avoid replacing an identity.

## Before migration

1. Back up important files and have a NixOS live USB available. Save this guide
   somewhere accessible from the live environment.
2. Confirm the device UUIDs below against `lsblk -f`.
   Check free space on `/nix`: it must hold the existing store **and** persisted
   state, including any containers in `/var/lib`.
3. Review data outside the persistence list, especially `/root`, `/opt`, `/srv`,
   and any service-specific directories. Move it or extend the configuration.
4. Record the current machine ID and SSH public-key fingerprints for comparison
   after boot. Do not publish private keys or password hashes.

On Ruby, build and install the next boot generation, **without activating it**:

```sh
sudo nixos-rebuild boot --flake path:.#ruby
```

Run this from the repository root. `path:.` includes the new module even before
Git tracks it; once committed, the usual `.#ruby` reference works too.
Do not use `switch` or `test` for the initial migration. Do not run Disko:
Ruby's `_disk-config.nix` describes the original installation, not this migration.
The persistence directory must be populated before booting the new generation.

## Copy state offline

Shut Ruby down cleanly, then boot the live USB. An offline copy avoids capturing
inconsistent databases or changing passwords/keys during the transfer.
Become root, then mount the old root read-only and the existing Nix filesystem
read-write. These commands do not format either filesystem:

```sh
sudo -i
mkdir -p /mnt/ruby-old-root /mnt/ruby-nix
mount -o ro /dev/disk/by-uuid/96e31197-ce71-4b8d-aa2b-eaf55648a76d /mnt/ruby-old-root
mount /dev/disk/by-uuid/90e457e4-df0a-4682-87af-0b66db7fa0ab /mnt/ruby-nix
```

If `/mnt/ruby-nix/persist` already exists, inspect it before proceeding. Do not
merge an unrelated or partially migrated persistence tree blindly. For a fresh
migration, copy metadata, ownership, ACLs, extended attributes and hard links:

```sh
install -d -m 0755 /mnt/ruby-nix/persist
cd /mnt/ruby-old-root
for path in etc var/lib var/log; do
  if [ -e "$path" ] || [ -L "$path" ]; then
    rsync -aHAXR --numeric-ids "$path" /mnt/ruby-nix/persist/ || exit 1
  fi
done
```

Stop and investigate any copy error. If `/etc/nixos` is a symlink, `rsync`
preserves it: ensure its target lives on `/home` or `/nix`, not the old root.
Missing optional files such as `subuid`/`subgid` are fine; machine ID, the SOPS
SSH private key, and account/password files must be present and identical:

```sh
test -s /mnt/ruby-nix/persist/etc/machine-id || exit 1
test -s /mnt/ruby-nix/persist/etc/ssh/host_ruby_ed25519_key || exit 1
for path in etc/machine-id etc/ssh/host_ruby_ed25519_key etc/passwd etc/group etc/shadow etc/gshadow; do
  cmp "/mnt/ruby-old-root/$path" "/mnt/ruby-nix/persist/$path" || exit 1
done
```

If the old `/var/lib/sops-nix/key.txt` exists, also verify it with `cmp`. Its
absence is acceptable only if the existing SSH key can decrypt all needed
secrets. Preserve SSH public keys and the standard OpenSSH host keys too; the
whole `/etc/ssh` directory above includes them. Ensure private-key permissions
are unchanged. The persistence root uses `0755`; access to secrets is restricted
by the copied directory and file permissions, just as on the original root.

Only continue if all required checks succeed:

```sh
cd /
sync
umount /mnt/ruby-old-root /mnt/ruby-nix
reboot
```

Remove the USB and select the newly installed NixOS generation.

## Verify and recover

- `findmnt -T /`, `findmnt -T /home`, and `findmnt -T /nix` should show tmpfs,
  ext4, and btrfs respectively.
- Compare `/etc/machine-id` and the SSH fingerprints with the originals.
- Confirm login, sudo, Wi-Fi, Bluetooth, and SOPS-backed Samba credentials work.
- Run `systemctl --failed` and inspect `journalctl -b -u sops-nix` if decryption fails.
- Create a disposable file under `/root`, reboot, and confirm it disappears while
  personal files and persistent state remain.

For rollback, select the preceding generation in systemd-boot (hold Space at
startup if the menu is hidden). It mounts the untouched ext4 root again. Its
system state is the pre-migration snapshot: subsequent changes in `/nix/persist`
are not copied back automatically. `/home` and `/nix`, including system profiles,
remain shared. Keep the old root and a known-good boot entry until satisfied.

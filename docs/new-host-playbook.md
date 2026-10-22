# NixOS host setup playbook

Use this playbook to add a host to the flake or install or reinstall a configured
host.

- [Prerequisites](#prerequisites)
- [Add a new host](#add-a-new-host-skip-for-an-existing-host)
- [Build an installer ISO](#build-an-installer-iso)
- [Install or reinstall a host](#install-or-reinstall-a-host)
- [Just commands](#just-commands)

## Prerequisites

- A Linux **configuration machine** with this repository checked out and Nix flakes enabled. Run repository commands from the checkout's root directory.
- `just` and `nixos-rebuild`. Run `nix develop` in the checkout to make these tools available.
- Access to private flake inputs, including `nix-private`, on each machine that evaluates the configuration.
- A NixOS installer ISO and network access for the **target machine**.

The configuration machine is where you edit and validate the flake. The target is the machine being installed; commands run in its live installer environment are labelled **On the installer**. Replace `<hostname>` with the configured host name and `<builder>` with the configuration machine's SSH destination.

## Add a new host (skip for an existing host)

1. **On the configuration machine:** create a host aspect and metadata entry:

   ```sh
   just new-host <hostname>
   ```

   This creates `dendritic/hosts/nixos/<hostname>/default.nix`.
   Edit it to set the correct user, state version, host description, aspects, and host-specific options.
   The generated host includes `(hardware <hostname>)`, so generate the matching hardware aspect next.

2. **On the target machine, in the installer:** boot a stock NixOS installer ISO and connect to the network. Capture hardware details from the target itself; a Disko-managed host should omit filesystems and swap:

   ```sh
   sudo nixos-generate-config --show-hardware-config --root / --no-filesystems \
     > /tmp/<hostname>-hardware.nix
   ```

   If installing to filesystems already mounted at `/mnt`, scan the installed root instead.
   Omit `--no-filesystems` only if the generated filesystem entries should be used by this host:

   ```sh
   sudo nixos-generate-config --show-hardware-config --root /mnt \
     > /tmp/<hostname>-hardware.nix
   ```

   Still on the target machine, copy the scan to the configuration machine:

   ```sh
   scp /tmp/<hostname>-hardware.nix <builder>:/tmp/<hostname>-hardware.nix
   ```

3. **On the configuration machine:** create the dendritic wrapper and module from the copied scan:

   ```sh
   just generate-hardware <hostname> --input /tmp/<hostname>-hardware.nix
   ```

   This writes a single `hardware.nix` module with the scan embedded in it.
   Review the result, especially kernel modules, platform, and any generated filesystem settings.
   If using Disko, create a host-specific disk layout such as `_disk-config.nix`, import it from the host aspect, and carefully verify its device paths before installing.

4. **On the configuration machine:** regenerate the flake and validate the host:

   ```sh
   just flake
   just check
   ```

   Commit or otherwise make the new configuration available to the build machine.
   Private inputs such as `nix-private` must be accessible there.

## Build an installer ISO

**On the configuration machine:** build the `iso-installer` image based on a host configuration:

```sh
just build-iso <hostname>
```

NixOS 25.05 and later provide `nixos-rebuild build-image`;
this recipe selects the built-in `iso-installer` image variant.
The image is linked at `result/iso/*.iso`.

On the machine holding the image and USB drive, copy the image using a graphical imaging tool or the command below.
Verify the USB device with `lsblk` first:

```sh
sudo dd if=result/iso/*.iso of=/dev/<usb-device> bs=4M status=progress conv=fsync
```

Replace `/dev/<usb-device>` with the whole USB device (for example `/dev/sdb`), not a partition. This overwrites that device.

## Install or reinstall a host

Choose the path that matches the target:

- **Existing host, fresh install:** skip host creation and hardware generation; use the existing host name below.
- **New host:** complete “Add a new host” and build the ISO after the new host configuration is available.

**On the installer:** perform all steps below on the target machine. After `sudo -i` in step 2, continue as root.

1. Boot the target from a NixOS installer ISO and connect it to the network. For a new host, identify the target disks (`lsblk`) and ensure the hardware or Disko configuration describes the intended devices.

2. Clone this repository on the installer somewhere outside `/mnt` (the target root will be mounted there later). For private inputs, authenticate to GitHub or provide the SSH agent/key needed to fetch them:

   ```sh
   sudo -i
   export NIX_CONFIG="experimental-features = nix-command flakes"
   nix flake clone github:manning390/nix-config --dest /root/nix-config
   cd /root/nix-config
   ```

   If `flake clone` is unavailable, use `git clone` instead.
   For an uncommitted new host, copy the working tree or push the host configuration first;
   a remote clone cannot include uncommitted changes.
   The installer needs credentials for private flake inputs (including `nix-private`) when Nix evaluates the configuration.
   Keep the checkout outside `/mnt` until it is copied into the installed root.

3. Prepare storage using exactly one applicable method. If using an existing host with static `fileSystems` in its hardware module, mount the filesystems at `/mnt` as declared there; if using Disko, run Disko to partition and mount them:

   - **Disko host:** inspect the host's `dendritic/hosts/nixos/<hostname>/_disk-config.nix` and verify every disk device before running the destructive format/mount operation:

     ```sh
     nix run github:nix-community/disko -- \
       --mode destroy,format,mount \
       --flake "/root/nix-config#nixosConfigurations.<hostname>"
     ```

   - **Non-Disko host:** partition, format, and mount filesystems manually under `/mnt` so they match the host's hardware configuration. Consult `dendritic/hosts/nixos/<hostname>/hardware.nix` for expected mount points.

4. Copy the config into the installed system and install the selected host:

   ```sh
   mkdir -p /mnt/etc
   cp -a /root/nix-config /mnt/etc/nixos
   nixos-install --flake "/mnt/etc/nixos#<hostname>"
   ```

   For a Disko host, the Disko module provides filesystem declarations.
   For a non-Disko host, the mounted filesystems must match the configuration.
   Set the root password when prompted if requested, then reboot and remove the USB drive.

## Just commands

| Command | Purpose |
| --- | --- |
| `just new-host <hostname> [--type nixos\|wsl]` | Generate a host aspect (defaults to `nixos`). |
| `just generate-hardware <hostname> --root <root> [--no-filesystems]` | Generate hardware details on the target/installer and the dendritic wrapper. |
| `just generate-hardware <hostname> --input <file>` | Create the dendritic wrapper from a hardware config copied from another machine. |
| `just build-iso <hostname>` | Build that NixOS configuration's installer ISO. |
| `just flake` | Regenerate the generated `flake.nix` from dendritic modules. |
| `just check` | Regenerate the flake and run `nix flake check`. |
| `just format` | Format the flake and Nix files. |

`just generate-hardware` expects a host directory created by `just new-host` and writes a `hardware.nix` module containing the generated hardware configuration.
Use the `--input` form when the host's hardware was collected on a different machine.
`just build-iso` supports existing NixOS hosts whose configuration evaluates with the `iso-installer` image variant.

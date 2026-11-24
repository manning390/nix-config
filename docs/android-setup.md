# Android host

This configures a **Nix-on-Droid terminal environment**, not Android itself or a
full NixOS installation. The host is `phone`, its type/aspect class is `android`,
and its output is `androidConfigurations.phone`. The
`nixOnDroidConfigurations.phone` alias supports upstream's activation command.
It currently installs Git, Neovim, OpenSSH, ripgrep, and tmux, without an SSH
server, privileged user, Home Manager integration, or deployment secrets.

Follow these steps in order. **An ARM64 Linux build VM is not an Android VM:
building there does not prove that activation works on Android.**

## 1. Prepare and review the configuration

1. Check out this repository's `android` branch on your trusted development
   machine. Review local changes before switching branches.
2. Review:
   - `dendritic/hosts/android/phone/default.nix`: phone-specific options.
   - `dendritic/systems/android.nix`: shared Android packages and settings.
   - `flake.lock`: the exact dependency versions to test and deploy.
3. Add compatible settings under `flake.aspects.<name>.android`. NixOS modules
   cannot generally be imported directly: Android has different system options.
   Reusing Home Manager settings requires an Android integration that is not
   implemented yet.
4. Resolve the **private-input dependency before deployment**. This flake
   references `nix-private` over SSH even though the phone does not import its
   modules. Fetching it may require authentication. Do not copy your normal
   GitHub/deployment keys or SOPS decryption keys to a test VM, emulator, or
   phone. Use narrowly scoped read-only access to the required repository only
   if its contents are appropriate for that device; otherwise separate the
   public phone configuration first. That separation is not implemented here.
5. Keep private keys, tokens, VPN credentials, and passwords out of Nix
   expressions, source archives, and the Nix store. Do not copy your entire home
   directory to any test environment.

## 2. Build in a disposable ARM64 Linux development VM

1. Create a VM with an **ARM64/AArch64 CPU and a 64-bit ARM Linux guest**,
   using an ARM64 installer image from the chosen distribution's official
   download site. Install NixOS, or install Nix in another Linux distribution
   using the [official instructions](https://nixos.org/download/).
   - On Apple Silicon, an ARM64 Linux VM can use hardware virtualization.
   - On Intel/AMD, use full-system ARM emulation, such as QEMU's
     `qemu-system-aarch64` with the `virt` machine and ARM UEFI firmware.
     An x86_64 VM or Docker container is **not** a substitute. Cross-architecture
     emulation uses software translation rather than KVM and can be slow.
   - This repository does not provision this development VM. Start with roughly
     4 CPUs, 8 GiB RAM, and 30 GiB free disk, expanding as needed.
2. Keep the VM disposable: use NAT networking, no inbound port forwarding, no
   production VPN membership, and no mounted home directory or SSH-agent
   forwarding. Transfer only reviewed configuration files. If private input
   access is unavoidable, use the restricted access described above.
3. Inside the guest, check the architecture and enable the Nix features used
   by this repository:

   ```sh
   uname -m  # Must report aarch64.
   nix --version
   export NIX_CONFIG=$'experimental-features = nix-command flakes pipe-operators'
   nix eval --impure --raw --expr builtins.currentSystem  # Must report aarch64-linux.
   ```

4. Transfer or clone the reviewed repository into the VM, enter its directory,
   and inspect the host:

   ```sh
   nix eval path:.#hostMetadata.phone
   nix eval --json path:.#androidConfigurations.phone.config.environment.packages \
     --apply 'packages: map (p: p.pname or p.name) packages'
   ```

5. Build the activation package with **VM-test-only app IDs**:

   ```sh
   nix build --impure --no-link --print-out-paths \
     --extra-substituters https://nix-on-droid.cachix.org \
     --extra-trusted-public-keys 'nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=' \
     --expr '
       let
         repo = builtins.getFlake ("path:" + toString ./.);
         tested = repo.inputs.flake-parts.lib.mkFlake {
           inputs = repo.inputs // { self = repo; };
         } {
           imports = [ (repo.inputs.import-tree ./dendritic) ];
           local.hosts.phone.extraModules = [{
             user.uid = 10000;
             user.gid = 10000;
           }];
         };
       in tested.androidConfigurations.phone.activationPackage
     '
   ```

   This uses the real host modules with temporary UID/GID overrides, without
   editing the phone configuration. The explicitly trusted upstream cache is
   needed for Nix-on-Droid's prebuilt PRoot; trust applies to this invocation,
   not permanently to the host. A multi-user Nix daemon may require an
   administrator to approve that substituter and signing key first. Do not
   disable signature checking or broadly grant Nix trusted-user privileges
   just to bypass a cache-permission error.

   **Do not run this activation package in the Linux VM or deploy it to the
   phone.** The IDs are fixtures, not the Android app's actual identity. A Linux
   VM cannot validate Android paths, PRoot behavior, or app permissions. A
   successful evaluation alone is not a successful build; wait for `nix build`
   to finish. Record the tested commit and lock file, and discard the VM when
   finished.

## 3. Test activation in ARM64 Android before using the phone

For a complete pre-phone test, use a disposable **ARM64 Android emulator** with
no production accounts, credentials, or access to your systems.

The packaged emulator currently supports ARM64 Android on **Apple Silicon**:

```sh
nix develop path:.#android
android-emulator --arm64
```

In another terminal, enter the same dev shell and verify the running guest:

```sh
adb devices
adb -e shell getprop ro.product.cpu.abi  # Must report arm64-v8a.
adb -e install /absolute/path/to/nix-on-droid.apk
```

Download the APK from [F-Droid](https://f-droid.org/packages/com.termux.nix/).
Open the app in the emulator and complete bootstrap. Transfer the reviewed
repository with `adb -e push`, using the shared-storage workflow below, then
copy it into the app's private home. **Inside Nix-on-Droid**, run:

```sh
nix-on-droid switch --flake path:./nix-config#phone
git --version
nvim --version
ssh -V
tmux -V
```

The flake path above assumes the repository was copied to `~/nix-config` and
the current directory is the app's home. Test opening a new terminal session,
editing disposable files, and SSH to an isolated test target with a throwaway
key. Test `nix-on-droid rollback` after a subsequent harmless configuration
change. Do not introduce production credentials to make these checks pass.

**On Intel/AMD Linux, the current dev shell cannot emulate ARM64 Android.**
An ARM64 Linux VM does not change that: the pinned SDK has no
`aarch64-linux` emulator binary. Use a supported ARM64 Android emulator host or
a spare ARM64 Android device. If neither is available, stop after VM build
validation until you can arrange an Android test device; do not treat the
x86 emulator as an equivalent pre-phone test. See
[Android testing](android-testing.md) for emulator details.

## 4. Install on the phone only after reviewing the test results

1. Update Android and use a strong unlock PIN/passphrase and short automatic
   lock timeout. Learn the device's Lockdown mode if disabling biometric unlock
   quickly matters to your threat model. Neither encryption nor Lockdown
   guarantees protection against an unlocked device or forensic access.
2. Install Nix-on-Droid from F-Droid and complete bootstrap. No root, SELinux
   changes, or additional Linux "sandbox" is needed. PRoot is **not** a strong
   security boundary.
3. On the trusted development machine:

   ```sh
   nix develop path:.#android
   ```

   Enable USB debugging temporarily on the phone, connect it by USB, and approve
   only this computer's debugging key. Check:

   ```sh
   adb devices
   adb -d shell getprop ro.product.cpu.abi  # Must report arm64-v8a.
   ```

   `-d` selects a physical USB device; `-e` selects an emulator. Use
   `-s SERIAL` from `adb devices` when multiple matching devices are connected.
   NixOS USB access may require host ADB/udev configuration; the dev shell does
   not grant device permissions.
4. Prepare a **reviewed** `nix-config` directory containing the tested source,
   lock file, and all referenced local files, without credentials. Grant the
   app storage access temporarily and transfer it:

   ```sh
   adb -d push ./nix-config /sdcard/Download/nix-config
   ```

   Run that command from the parent of the prepared directory, not from inside
   it. Inside the phone's Nix-on-Droid app:

   ```sh
   cp -r /sdcard/Download/nix-config ~/nix-config
   nix-on-droid switch --flake path:./nix-config#phone
   ```

   Start in the app's home and copy to a fresh destination. Do not transfer the
   VM's generated activation package or its UID/GID overrides. Upstream must
   discover the phone app's own identity. ADB runs as Android's shell user, so
   `adb shell nix-on-droid ...` is not a replacement for running inside the app.
5. Repeat the basic tool checks. Remove the shared-storage transfer copy,
   revoke unnecessary storage access, disable USB debugging, and revoke its
   debugging authorizations. Keep configuration in the app's private home.

## 5. Grant narrowly restricted remote access

1. Install the Android Tailscale or WireGuard app separately. Allow the phone
   to reach only the required machines and SSH ports; do not expose SSH or a
   browser terminal publicly for convenience.
2. Generate a **phone-only, passphrase-protected** key inside Nix-on-Droid:

   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_mobile -C android-phone
   ```

   Choose a strong passphrase at the prompt. Never copy your main administrator
   key to the phone or put this key in Nix configuration. Avoid keeping keys
   unlocked indefinitely in an agent.
3. From a trusted admin machine, authorize only the phone's **public** key on a
   separate unprivileged mobile account on each intended server. Restrict file
   permissions and group memberships to the required repositories/status data.
   Avoid broad read access, unrestricted sudo, `docker` membership, deployment
   credentials, or write access to scripts/services run by privileged users.
   Editing and activating arbitrary NixOS configuration as root is effectively
   administrator access.
4. On the servers, disable password-based SSH and direct root SSH login after
   confirming a separate recovery/admin path. Disable agent, TCP, and other
   forwarding for the mobile account unless explicitly needed. OpenSSH's
   `restrict` authorized-key option is useful, but it also disables PTYs; an
   interactive terminal needs an intentional exception such as `restrict,pty`.
   Key restrictions do not restrict which commands an otherwise unrestricted
   shell can execute; account permissions must enforce the actual boundaries.
5. Test access and denial: the phone should reach the intended SSH endpoints,
   but should not read unrelated files, use sudo, or reach prohibited services.
   The VPN is an additional gate, **not** a replacement for SSH authentication.
   A web editor/terminal has the permissions of its server account and is not
   inherently safer.

For stronger protection against new logins from a stolen phone, consider a
separately carried touch-required FIDO2 SSH key only after confirming support
in the actual Android client/device setup. It does not stop use of an already
authenticated session.

## 6. Prepare for loss, theft, or confiscation

Assume an unlocked or compromised phone can expose readable files and active
sessions even if its SSH key has a passphrase. Keep sensitive local files to a
minimum. From a different trusted device, rehearse how to:

1. Revoke the phone's VPN device/peer and any identity-provider sessions.
2. Remove its dedicated SSH public key from every authorized account.
3. Terminate existing SSH sessions and processes for that mobile account;
   removing the key alone does not disconnect authenticated sessions.
4. Revoke any Git/input-fetch credentials stored on the phone and rotate any
   other secrets it could access. Review server logs.

Keep recovery access and the device/key inventory somewhere other than the
phone. Do not rely on remote wipe: the device may be offline. Restrictions on
the servers are what limit the damage after phone compromise.

See [Android phone host](android-host.md) for dispatcher details and
[Android testing](android-testing.md) for the dev shell and ADB workflow.

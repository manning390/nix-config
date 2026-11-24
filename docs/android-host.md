# Android phone configuration

The `android` branch contains an `android` terminal host backed by Nix-on-Droid:

- Host: `dendritic/hosts/android/phone/default.nix`
- Shared Android settings: `dendritic/systems/android.nix`
- Flake output: `androidConfigurations.phone`
- CLI compatibility alias: `nixOnDroidConfigurations.phone`
- Architecture: `aarch64-linux`

This configures the Nix-on-Droid app environment, not Android itself. It installs
Git, Neovim, OpenSSH, ripgrep, and tmux. It does not enable an SSH server, import
the NixOS base, copy credentials, grant sudo, or register a deploy-rs target.
Use the Android Tailscale/WireGuard app for VPN connectivity.

## Install and activate

1. Install [Nix-on-Droid from F-Droid](https://f-droid.org/packages/com.termux.nix/)
   and complete its initial bootstrap.
2. Transfer or clone this repository at the `android` branch into the app's
   private home. For USB transfer and emulator limitations, see
   [Android testing](android-testing.md).
3. Inside Nix-on-Droid, from the repository directory:

   ```sh
   nix-on-droid switch --flake .#phone
   ```

   For a local copy with new files not yet tracked by Git, use
   `nix-on-droid switch --flake path:.#phone` instead.

The upstream command performs impure evaluation because Android-specific
bootstrap paths and app identity are discovered at runtime. Leave `user.uid`
and `user.gid` unset: they must match the actual app installation, not a desktop
user or an arbitrary test value. The host's `system.stateVersion = "24.05"`
tracks Nix-on-Droid compatibility, independently of the Nixpkgs release.

**Private input caveat:** this repository has an SSH-authenticated `nix-private`
input. Fetching the full flake on a fresh phone may require access to it even
though the phone does not import its modules. Do not copy a general-purpose
GitHub or deployment key onto the phone. Use narrowly scoped read-only access
if necessary, or separate the public phone configuration before deployment.
This change does not remove that repository-wide dependency.

Generate a separate passphrase-protected SSH key on the phone and authorize
only its public key on restricted server accounts. Private keys must not be
put in Nix expressions or the Nix store.

## Dispatcher integration

`dendritic/hosts/default.nix` adds an `android` dispatcher entry with aspect
class `android`. It adapts the existing builder arguments to upstream's
`pkgs`, `extraSpecialArgs`, and `modules` interface.

Android aspects are resolved directly instead of importing the class-tagged
`flake.modules.android` wrappers: upstream's evaluator requires the internal
module class `nixOnDroid`. This keeps declarations as `aspects.<name>.android`
without changing upstream. The output alias preserves upstream CLI compatibility.

The only shared assembly change is an optional `hostDefaults` hook. Existing
hosts still receive the same identity and hostname defaults; Android opts out
because Android manages the app user and hostname. The common state-version,
host/type aspects, extra modules, and host metadata mechanisms are unchanged.
The existing deployment filter excludes Android automatically.

Add phone-specific options under `flake.aspects.phone.android`. Do not
include the existing NixOS `base` or user aspects indiscriminately. Home Manager
integration is not enabled yet; the existing integration assumes NixOS users
and `/home/<username>` and needs a separate Android adapter before reuse.

Nix-on-Droid and Home Manager follow the repository's Nixpkgs/Home Manager
inputs, rather than introducing an old userspace package set. Upstream retains
its own bootstrap dependencies. Recheck compatibility when updating inputs.

## Desktop validation

Inspect the host without evaluating its runtime-dependent activation script:

```sh
nix eval path:.#hostMetadata.phone
nix eval path:.#androidConfigurations.phone.config.system.stateVersion
nix eval --json path:.#androidConfigurations.phone.config.environment.packages \
  --apply 'packages: map (p: p.pname or p.name) packages'
```

Evaluating the complete activation package on a desktop requires upstream's
prebuilt PRoot in the local Nix store. If needed, explicitly trust its cache
for that command (this does not modify host configuration):

```sh
nix eval --impure \
  --extra-substituters https://nix-on-droid.cachix.org \
  --extra-trusted-public-keys 'nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=' \
  --raw path:.#androidConfigurations.phone.activationPackage.drvPath
```

Even with the cache, this can fail on an x86_64 desktop because upstream runs
an ARM64 derivation to discover the app UID/GID. A remote ARM64 builder does
not discover the phone's actual app identity. Use the device for real activation;
test-only UID/GID overrides can validate evaluation but must never be deployed.

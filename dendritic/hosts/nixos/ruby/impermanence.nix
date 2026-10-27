{
  flake.modules.nixos.impermanence-ruby = {
    config,
    inputs,
    lib,
    ...
  }: {
    imports = [inputs.impermanence.nixosModules.impermanence];

    # Keep the existing root partition intact for migration and rollback.
    # /home and /nix retain their existing devices from hardware.nix.
    fileSystems."/" = {
      device = lib.mkForce "none";
      fsType = lib.mkForce "tmpfs";
      options = ["size=4G" "mode=755"];
    };
    fileSystems."/nix".neededForBoot = true;
    # Mutable accounts are atomically rewritten during activation. Mount their
    # containing directory early rather than bind-mounting individual files
    # after users/groups have already been initialized. This also makes the
    # existing machine-id available before stage-2 systemd starts.
    fileSystems."/etc" = {
      device = "/nix/persist/etc";
      fsType = "none";
      options = ["bind"];
      depends = ["/nix"];
      neededForBoot = true;
    };

    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        # Preserve service state broadly during this root-only migration,
        # including SOPS age keys, Bluetooth pairings and container data.
        "/var/lib"
        "/var/log"
      ];
    };

    # Use the backing paths even before impermanence's /var/lib mount is
    # established. Never silently replace a missing decryption identity.
    local.sops.generateKeys = false;
    sops.age = {
      sshKeyPaths = lib.mkForce [
        "/nix/persist/etc/ssh/host_${config.networking.hostName}_ed25519_key"
      ];
      keyFile = lib.mkForce "/nix/persist/var/lib/sops-nix/key.txt";
      generateKey = lib.mkForce false;
    };
  };
}

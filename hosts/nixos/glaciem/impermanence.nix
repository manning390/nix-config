{vars, ...}: {
  # Impermanence config
  # List what should be kept
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/home"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/host_${vars.hostname}_ed25519_key"
      "/etc/ssh/host_${vars.hostname}_ed25519_key.pub"
    ];
  };
}

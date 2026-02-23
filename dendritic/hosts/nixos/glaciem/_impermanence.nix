{config, inputs,...}: let
  hostname = config.networking.hostName;
  user = config.local.identity.username;
in {
  imports = [inputs.impermanence.nixosModules.impermanence];
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
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/host_${hostname}_ed25519_key"
      "/etc/ssh/host_${hostname}_ed25519_key.pub"
    ];

    users.${user} = {
      directories = [
        "nix-config"
        ".ssh"
      ];
    };
  };
}

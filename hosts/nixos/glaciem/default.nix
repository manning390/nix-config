{
  config,
  lib,
  vars,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
      ./disk-config.nix
      ./impermanence.nix
    ]
    ++ builtins.map lib.custom.relativeToRoot [
      "modules/system.nix"
      "modules/sops.nix"
      "modules/zsh.nix"
    ];

  # Custom module options
  custom = {
    sops.enable = true;
  };

  # Descrypt password so it can be used to create the user
  sops.secrets."user_passwords/glaciem".neededForUsers = true;
  # users.mutableUsers = false; # Required for password to be set via sops during system activations!
  users.users.${vars.username} = {
    isNormalUser = true;
    # hashedPasswordFile = config.sops.secrets."user_passwords/glaciem".path;
    description = vars.userfullname;
    extraGroups = ["wheel"];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ./keys/user_pch_glaciem_ed25519_key.pub)
    ];
  };

  networking = {
    hostName = vars.hostname;
    hostId = "9dea9b66";
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "25.05";
}

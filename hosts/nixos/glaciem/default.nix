{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  hardDrives = [ ];
in {
  imports =
    [
      ./hardware-configuration.nix
      ./disk-config.nix
      ./impermanence.nix
      ./homelab.nix
    ]
    ++ builtins.map lib.custom.relativeToRoot [
      "modules/nix.nix"
      "modules/common.nix"
      "modules/sops.nix"
      "modules/shells.nix"
      "modules/homelab"
    ];

  # Custom module options
  custom = {
    shells = {
      systemShell = "bash";
      userShell = "fish";
    };
    sops.enable = true;
    sops.generateKeys = false;
    nix = {
      flakePath = "/home/${vars.username}/nix-config";
    };
  };

  # Homelab module options
  homelab = {
    enable = true;
    baseDomain = "glaciem.home";

    samba = {
      enable = true;
      passwordFile = config.sops.secrets."samba_password".path;
      shares = {
      };
    };
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
    networkmanager.enable = false;
    useDHCP = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
    };
  };

  # systemd.services.hd-idle = {
  #   description = "External HD spin down daemon";
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = let
  #       idleTime = toString 900;
  #       hardDriveParameter = lib.strings.concatMapStringSep " " (x: "-a ${x} ie ${idleTime}") hardDrives;
  #     in "${pkgs.hd-idle}/bin/hd-idle -i 0 ${hardDriveParameter}";
  #   };
  # };

  environment.systemPackages = with pkgs; [
    pciutils
    glances
    hdparm
    hd-idle
    hddtemp
    cpufrequtils
    powertop
  ];

  system.stateVersion = "25.05";
}

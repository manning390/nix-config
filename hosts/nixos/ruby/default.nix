# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  pkgs,
  vars,
  ...
}:
with myvars; let
  username = "ruby";
  hostName = "ruby";
in {
  imports =
    [
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ./hardware-configuration.nix
    ]
    ++ builtins.map lib.custom.relativeToRoot [
      "modules/common.nix"
      "modules/nix.nix"
      "modules/zsh.nix"
      "modules/audio.nix"
      "modules/browsers.nix"
      "modules/hyprland.nix"
      # "modules/gaming/steam.nix"
      "modules/gaming/ffxiv.nix"
      # "modules/stylix.nix"
      # "modules/keyd.nix"
      "modules/keyboard.nix"
      "modules/zsa.nix"
      "modules/laptop.nix"
    ];

  custom = {
    ffxiv.enable = false;
    sops.enable = true;
    sops.homeOnSeparatePartition = true;
    stylix.enable = true;
    colemak_dhm.enable = true;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  # Networking
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };
  hardware.bluetooth.enable = true;



  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Users
  users.users."${username}" = {
    isNormalUser = true;
    description = vars.userfullname;
    extraGroups = ["networkmanager" "wheel" "audio" "docker" "video"];
    openssh.authorizedKeys.keys = [];
  };

  # Given the users in this list the right to specify additional substituters via:
  #    1. `nixConfig.substituers` in `flake.nix`
  #    2. command line args `--options substituers http://xxx`
  nix.settings.trusted-users = [username];

  # System packages
  environment.systemPackages = with pkgs; [
    #   # Utils
    #   vim # Do not remove, need an editor to edit configuration.nix
    #   zsh
    #   git
    #   btop
    #   bat
    #   wget
    #   curl
    #   tree
    #   stow
    #   usbutils
    brightnessctl
    zoom-us
  ];

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  #virtualisation.docker.enable = true;
  services.fwupd.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}

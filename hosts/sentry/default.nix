# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/system.nix
    ../../modules/hyprland.nix
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  # Bootloader 
  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Shell
  environment.shells= with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Hostname
  networking.hostName = "sentry";

  # Networking
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true; 

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Users
  users.users = {
    rail = {
      isNormalUser = true;
      description = "Michael Manning";
      extraGroups = ["networkmanager" "wheel" "audio"];
      openssh.authorizedKeys.keys = [ ];
      shell = pkgs.zsh;
    };
  };

  # Given the users in this list the right to specify additional substituters via:
  #    1. `nixConfig.substituers` in `flake.nix`
  #    2. command line args `--options substituers http://xxx`
  nix.settings.trusted-users = ["rail"];

  # System packages
  # environment.systemPackages = with pkgs; [
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
  # ];

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = false;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}

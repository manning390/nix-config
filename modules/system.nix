{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  # Garbage Collection
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "daily";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set timezone
  time.timeZone = "America/Los_Angeles";

  # Inernationaliration properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Fonts fonts fonts
  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.noto
    ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    vim # Do not remove, need an editor to edit configuration.nix

    zsh

    wget
    curl
    git
    stow
    wl-clipboard
    just

    # archives
    zip
    unzip
    p7zip

    # utils
    ripgrep
    fzf
    htop
    pciutils

    # networking
    nmap

    # Drives
    usbutils
    udiskie
    udisks

    # Security
    sops
    gnupg
    pinentry-curses
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # USB Services
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  boot.supportedFilesystems = ["exfat"];
}

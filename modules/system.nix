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
  # nix.gc = {
  #   automatic = lib.mkDefault true;
  #   dates = lib.mkDefault "weekly";
  #   options = lib.mkDefault "--delete-older-than 7d";
  # };

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
      # Nerdfonts is too big, only grab what we want
      (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono" "Noto"];})
    ];
  };

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    neovim
    firefox
    zsh

    vim # Do not remove, need an editor to edit configuration.nix
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
    usbutils

    # networking
    nmap
  ];
}

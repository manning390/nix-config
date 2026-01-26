{pkgs, ...}: {
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

    fastfetch
    zsh

    wget
    curl
    git
    eza # ls replacement
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

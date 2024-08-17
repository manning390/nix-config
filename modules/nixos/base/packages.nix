{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
  neofetch
  neovim # Do not forget to add an editor to edit configuration.nix!
  zsh
  bat

  #   wget
  #   curl
  #   tree
  #   stow

  # system monitoring
  sysstat
  iotop
  iftop
  btop
  nmon
  sysbench

  # system tools
  psmisc
  ethtool
  pciutils
  usbutils

  ];

  environment.variables.EDITOR = "nvim";
}

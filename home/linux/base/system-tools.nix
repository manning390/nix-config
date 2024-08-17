{pkgs, ...}: {
# Linux only packages, not on darwin
  home.packages = with pkgs; [
    libnotify
  ];

# auto mount usb drives
  services = {
      udiskie.enable = true;
  };
}

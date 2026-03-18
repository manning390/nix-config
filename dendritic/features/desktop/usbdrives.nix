{
  flake.aspects.usbdrives = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        usbutils
        udiskie
        udisks
      ];
      services.udisks2.enable = true;
      services.gvfs.enable = true;
      boot.supportedFilesystems = ["exfat"];
    };
  };
}

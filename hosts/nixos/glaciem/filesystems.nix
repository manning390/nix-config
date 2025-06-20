{...}: {
  # Manually mount the zfs filesystems to the datasets
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/3D16-756E";
      fsType = "vfat";
    };

    "/" = {
      device = "system-pool/root";
      fsType = "zfs";
      options = ["zfsutil"];
    };
    "/persist" = {
      device = "system-pool/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/nix" = {
      device = "system-pool/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "system-pool/home";
      fsType = "zfs";
    };
    "/var" = {
      device = "system-pool/var";
      fsType = "zfs";
    };
    "/mnt/ssd" = {
      device = "ssd-pool/data";
      fsType = "zfs";
    };
    "/mnt/hdd" = {
      device = "hdd-pool/data";
      fsType = "zfs";
    };
    "/mnt/backups" = {
      device = "hdd-pool/backups";
      fsType = "zfs";
    };
  };
}

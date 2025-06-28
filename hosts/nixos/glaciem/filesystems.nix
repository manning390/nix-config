{...}: {
  # Manually mount the zfs filesystems to the datasets
  # fileSystems = {
  #   "/" = {
  #     device = "system-pool/root";
  #     fsType = "zfs";
  #     options = ["zfsutil"];
  #   };
  #   "/persist" = {
  #     device = "system-pool/persist";
  #     fsType = "zfs";
  #     neededForBoot = true;
  #   };
  #   "/nix" = {
  #     device = "system-pool/nix";
  #     fsType = "zfs";
  #   };
  #   "/var" = {
  #     device = "system-pool/var";
  #     fsType = "zfs";
  #   };
  #   "/home" = {
  #     device = "system-pool/home";
  #     fsType = "zfs";
  #   };
  # };

  boot.supportedFilesystems = ["zfs"]; # Actually support the filesystem
  # boot.zfs.devNodes = "/dev/disk/by-partuuid"; # Where to look to boot from
  boot.zfs.extraPools = ["ssd-pool" "hdd-pool"]; # Other non-root pools that auto mount
}

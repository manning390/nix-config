{...}: {
  # Manually mount the zfs filesystems to the datasets
  fileSystems = {
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
    "/var" = {
      device = "system-pool/var";
      fsType = "zfs";
    };
    "/home" = {
      device = "system-pool/home";
      fsType = "zfs";
    };
  };

  boot.zfs.extraPools = ["ssd-pool" "hdd-pool"];
}

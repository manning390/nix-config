{
  disko.devices = {
    disk = {
      # NVMe for ZFS root pool 
      nvme0 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Vi3000_Internal_PCIe_NVMe_M.2_SSD_256GB_493734394832852";
        content = {
          type = "gpt";
          partitions = {
            efi = {
              size = "1G";
              type = "EF00"; # EFI System Partition GUID
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs-system = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "system-pool";
              };
            };
          };
        };
      };

      # SSD
      ssd0 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WD_Red_SA500_2.5_2TB_24114M4A1K11";
        content = {
          type = "gpt";
          partitions = {
            zfs-ssd = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "ssd-pool";
              };
            };
          };
        };
      };

      # HDD
      hdd0 = {
        device = "/dev/disk/by-id/ata-ST12000NM0127_ZJV1TD7E";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs-hdd = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "hdd-pool";
              };
            };
          };
        };
      };

    };

    zpool = {
      # System/root pool
      system-pool = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          "root" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              canmount = "noauto";
            };
          };
          "nix" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              atime = "off";
            };
          };
          "persist" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
          };
          "home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
          };
          "var" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
          };
        };
      };

      # Bulk data pool
      hdd-pool = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "off";
        };
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          "data" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
          };
          "backups" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
          };
        };
      };

      # Fast SSD pool
      ssd-pool = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          "data" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}

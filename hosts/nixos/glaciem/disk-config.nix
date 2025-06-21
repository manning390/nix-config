{
  disko.devices = {
    disk = {
      # NVMe for ZFS root pool ("system")
      nvme = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            efi = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs_system = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "system";
              };
            };
          };
        };
      };

      # HDD for persistent data pool ("vault")
      hdd1 = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs_vault = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "vault";
              };
            };
          };
        };
      };

      # SSD for fast data pool ("fast")
      ssd1 = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs_fast = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "fast";
              };
            };
          };
        };
      };
    };

    zpool = {
      # System/root pool
      system = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
        };
      };

      # Bulk data pool (now called "vault")
      vault = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };
          "safe/backups" = {
            type = "zfs_fs";
            mountpoint = "/backups";
            options.mountpoint = "legacy";
          };
          "safe/data" = {
            type = "zfs_fs";
            mountpoint = "/data";
            options.mountpoint = "legacy";
          };
        };
      };

      # Fast SSD pool
      fast = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
          "safe/vms" = {
            type = "zfs_fs";
            mountpoint = "/vms";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}

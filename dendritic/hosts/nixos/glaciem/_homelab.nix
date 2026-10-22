{config, ...}: let
  hl = config.homelab;
in {
  sops.secrets.restic_password = {
    owner = "root";
    mode = "0400";
  };

  # Homelab module options
  homelab = {
    enable = true;
    baseDomain = "glaciem.home";

    mounts = {
      fast = "/fast";
      slow = "/bulk";
    };

    samba = {
      server.enable = true;
    };

    backups = {
      enable = true;
      generatePassword = false;
      passwordFile = config.sops.secrets.restic_password.path;
      sources = {
        fast = {
          dataset = "ssd-pool/data";
          mountpoint = "/fast";
        };
        bulk = {
          dataset = "hdd-pool/data";
          mountpoint = "/bulk";
        };
        home = {
          dataset = "system-pool/home";
          mountpoint = "/home";
        };
        persist = {
          # Impermanence bind-mounts /persist/var/lib at /var/lib.
          dataset = "system-pool/persist";
          mountpoint = "/persist";
        };
        configuration = {
          dataset = "system-pool/root";
          mountpoint = "/";
          paths = ["/etc"];
        };
      };
    };

    services = {
      enable = true;
      homepage.enable = true;
      forgejo.enable = true;
      immich.enable = true;
      audiobookshelf.enable = true;
      pihole.enable = true;
      memos.enable = true;
      uptimekuma.enable = true;
      deluge.enable = true;
      paperless.enable = true;
      # filebrowser.enable = true;
      microbin.enable = true;
      #   role = "server";
      # };
    };
  };
}

{
  config,
  ...
}: let
  hl = config.homelab;
in {
  # Homelab module options
  homelab = {
    enable = true;
    baseDomain = "glaciem.home";

    mounts = {
      fast = "/fast";
      slow = "/bulk";
      backups = "/backups";
    };

    samba = {
      enable = true;
      shares = {
        Fast = {
          path = "${hl.mounts.fast}";
        };
        Media = {
          path = "${hl.mounts.slow}/Media";
        };
        Backups = {
          path = hl.mounts.backups;
        };
      };
    };

    services = {
      enable = true;
      homepage.enable = true;
      microbin = {
        enable = true;
        role = "server";
      };
    };
  };
}

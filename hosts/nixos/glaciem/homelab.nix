{
  config,
  inputs,
  pkgs,
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
      passwordFile = config.sops.secrets."samba_password".path;
      shares = {
        Photos = {
          path = "${hl.mounts.fast}/Photos";
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

      homepage = {
        enable = false;
      };
    };
  };
}

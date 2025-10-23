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

    samba = {
      enable = true;
      passwordFile = config.sops.secrets."samba_password".path;
      shares = {
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

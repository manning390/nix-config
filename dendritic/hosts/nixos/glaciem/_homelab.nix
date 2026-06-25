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
    };

    samba = {
      server.enable = true;
    };

    services = {
      enable = true;
      homepage.enable = true;
      filebrowser.enable = true;
      # microbin = {
      #   enable = false;
      #   role = "server";
      # };
    };
  };
}

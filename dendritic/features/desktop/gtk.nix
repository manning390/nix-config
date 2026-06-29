{
  flake.aspects.gtk.homeManager = {pkgs, ...}: {
    gtk = {
      enable = true;
      gtk4.theme = null;
      theme = {
        package = pkgs.nordic;
        name = "Nordic";
      };
    };
    home.packages = with pkgs; [
      nwg-look
    ];
  };
}

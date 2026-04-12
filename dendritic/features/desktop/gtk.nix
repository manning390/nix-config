{
  flake.aspects.gtk.homeManager = {pkgs, ...}: {
    gtk = {
      enable = true;
      theme = {
        package = pkgs.nordic;
        name = "Nordic";
      };
    };
  };
}

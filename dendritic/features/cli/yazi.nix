{
  flake.aspects.yazi.homeManager = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
    };
  };
}

{
  config,
  username,
  ...
}: let
d = config.xdg.dataHome;
c = config.xdg.configHome;
cache = config.xdg.cacheHome;
in rec {
  home.homeDirectory = "/home/${username}";

  # environment variables that always set at login
  home.sessionVariables = {
    # LESSHISTFILE = cache + "/less/history";
    # LESSKEY = c + "/less/lesskey";
    # WINEPREFIX = d + "/wine";

    BROWSER = "brave";

    # Enable scrolling in git diff
    DELTA_PAGER = "less -R";
  };
}

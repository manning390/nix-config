{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  home.sessionVariables = {
    COLEMAK = "1";
  };
}

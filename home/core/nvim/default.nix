{
  pkgs,
  lib,
  ...
}: {
  # programs.neovim = {
  #   enable = true;
  #
  #   defaultEditor = true;
  #
  #   viAlias = true;
  #   vimAlias = true;
  #   vimdiffAlias = true;
  #
  #   plugins = with pkgs.vimPlugins; [
  #
  #   ];
  # };

  home.sessionVariables = {
    COLEMAK = "1";
  };
}

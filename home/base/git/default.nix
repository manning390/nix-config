{
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    userName = "Michael Manning";
    userEmail = lib.mkDefault "michael@manning390.com";
  };
}

{
  pkgs,
  lib,
  myvars,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    userName = myvars.userfullname;
    userEmail = lib.mkDefault myvars.useremail;
  };
}

{pkgs, ...}: let
  wiki = pkgs.callPackage ./wiki.nix {};
in {
  home.packages = [wiki];
}

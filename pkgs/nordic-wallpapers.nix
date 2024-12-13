{
  lib,
  stdenv,
  fetchFromGitHub,
}: let
  repo = fetchFromGitHub {
    owner = "linuxdotexe";
    repo = "nordic-wallpapers";
    rev = "master";
    sha256 = "sha256-rDlhp5bkFoHcIRq+SASk34nzcS9MJ63yR46/RBYL7AQ="; 
  };
  mkWallpaper = name:
    stdenv.mkDerivation {
      pname = "nordic-wallpaper-${name}";
      version = "1.0.0";
      src = repo;
      installPhase = ''
        mkdir -p $out/share/wallpapers
        cp ${name}.png $out/share/wallpapers/
      '';
    };
in {
  wallpapers = lib.mapAttrs (name: _: mkWallpaper name) (builtins.readDir "${repo}");
}

{
  lib,
  stdenv,
  fetchFromGitHub,
}: let
  repo = fetchFromGitHub {
    owner = "linuxdotexe";
    repo = "nordic-wallpapers";
    rev = "master";
    sha256 = "sha256-KDkTnEBdL/DQ7ZJ62t3vTAO3OwE69KDsQ5gSTWh84GM=";
  };
  mkWallpaper = name:
    stdenv.mkDerivation {
      pname = "nordic-wallpaper-${name}";
      version = "1.0.0";
      src = repo;
      installPhase = ''
        mkdir -p $out
        cp $src/wallpapers/${name}.png $out/
      '';
    };
  allWallpapers = stdenv.mkDerivation {
    pname = "nordic-wallpapers-all";
    version = "1.0.0";
    inherit repo;
    installPhase = ''
      mkdir -p $out
      cp $src/wallpapers/*.png $out/
    '';
  };
  wallpaperFiles = builtins.attrNames (builtins.readDir "${repo}/wallpapers");
  stripExtension = name: builtins.elemAt (builtins.split "\\." name) 0;
  wallpaperNames = map stripExtension wallpaperFiles;
  individualWallpapers = lib.genAttrs wallpaperNames (name: mkWallpaper name);
in
  individualWallpapers // { all = allWallpapers; }


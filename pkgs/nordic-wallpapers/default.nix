{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
}: let
  # Function to fetch a single file from GitHub
  fetchGitHubFile = {
    owner,
    repo,
    rev,
    path,
    sha256,
  }:
    fetchurl {
      url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${path}";
      sha256 = sha256;
    };
  removeExtension = file: lib.strings.removeSuffix ".jpg" (lib.strings.removeSuffix ".png" file);

  wallpaperHashes = import ./wallpapers.nix;

  # Function to create a derivation for a single wallpaper
  mkWallpaper = name:
    stdenv.mkDerivation {
      pname = "nordic-wallpaper-${removeExtension name}";
      version = "1.0.0";
      src = fetchGitHubFile {
        owner = "linuxdotexe";
        repo = "nordic-wallpapers";
        rev = "master";
        path = "wallpapers/${name}";
        sha256 = wallpaperHashes.${name};
      };
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out
        cp $src $out/${name}
      '';
    };

  # Create derivations for all specified wallpapers
  individualWallpapers = builtins.listToAttrs (map (name: {
    name = removeExtension name;
    value = mkWallpaper name;
  }) (builtins.attrNames wallpaperHashes));

  # Create a derivation for all wallpapers if needed
  allWallpapers = stdenv.mkDerivation {
    pname = "nordic-wallpapers-all";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "linuxdotexe";
      repo = "nordic-wallpapers";
      rev = "master";
      sha256 = "sha256-KDkTnEBdL/DQ7ZJ62t3vTAO3OwE69KDsQ5gSTWh84GM=";
    };
    installPhase = ''
      mkdir -p $out
      cp $src/wallpapers/* $out/
    '';
  };
in
  individualWallpapers // {all = allWallpapers;}

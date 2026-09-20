let
  mkNordicWallpapers = pkgs: let
    inherit (pkgs) lib stdenv fetchurl fetchFromGitHub;

    fetchGitHubFile = {
      owner,
      repo,
      rev,
      path,
      sha256,
    }:
      fetchurl {
        url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${path}";
        inherit sha256;
      };
    removeExtension = file: lib.strings.removeSuffix ".jpg" (lib.strings.removeSuffix ".png" file);
    wallpaperHashes = import ./_wallpapers.nix;

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

    individualWallpapers = builtins.listToAttrs (map (name: {
      name = removeExtension name;
      value = mkWallpaper name;
    }) (builtins.attrNames wallpaperHashes));

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
    individualWallpapers // {all = allWallpapers;};
in {
  flake.overlays.nordic-wallpapers = final: _: {
    nordic-wallpapers = mkNordicWallpapers final;
  };

  perSystem = {pkgs, ...}: let
    wallpapers = mkNordicWallpapers pkgs;
  in {
    legacyPackages.nordic-wallpapers = wallpapers;
    packages.nordic-wallpapers-all = wallpapers.all;
  };
}

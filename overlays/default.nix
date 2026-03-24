# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    xivlauncher = prev.xivlauncher.overrideAttrs (old: {
      postFixup = let
        steam-run = (prev.steam.override {
          extraPkgs = pkgs: [ prev.libunwind ] ++ [ prev.gamemode ];
          extraProfile = ''
            unset TZ
          '';
        }).run;
      in ''
        # Replace exec with steam-run wrapper
        substituteInPlace $out/bin/XIVLauncher.Core \
          --replace-fail 'exec' "exec ${steam-run}/bin/steam-run"

        # Keep their GST_PlUGIN fix
        wrapProgram $out/bin/XIVLauncher.Core \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 ":" "$GST_PLUGIN_SYSTEM_PATH_1_0"

        # aria2 dependency fix
        mkdir -p $out/nix-support
        echo ${prev.aria2} >> $out/nix-support/depends
      '';
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}

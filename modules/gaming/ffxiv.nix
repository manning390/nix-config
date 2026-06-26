{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.ffxiv.enable = lib.mkEnableOption "enables ffxiv";

  config = lib.mkIf config.local.ffxiv.enable {
    environment.systemPackages = with pkgs; [
      xivlauncher
    ];
    programs.gamemode.enable = true;

    nixpkgs.overlays = [
      (self: super: {
        xivlauncher = super.xivlauncher.overrideAttrs (old: {
          postFixup = let
            steam-run =
              (super.steam.override {
                extraPkgs = pkgs: [super.libunwind] ++ [super.gamemode];
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
            echo ${super.aria2} >> $out/nix-support/depends
          '';
        });
      })
    ];
  };
}

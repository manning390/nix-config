{
  flake.aspects.gaming._.ffxiv = {
    description = ''
      The acritically acclaimed MMORPG Final Fantasy XIV with an expanded free trial which you can play through the entirety of A Realm Reborn and the award winning Heavensward expansion and also award winning Shadowbringers expansion up to level 80 for free with no restrictions on playtime.
    '';

    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.local.ffxiv;
    in {
      options.local.ffxiv.enable = lib.mkEnableOption "Enables FFXIV via xivlauncher";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.xivlauncher
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
    };
  };
}

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
          pkgs.unstable.xivlauncher
        ];
        programs.gamemode.enable = true;
        nixpkgs.overlays = [
          (_: prev: {
            unstable = prev.unstable.extend (_: unstablePrev: {
              xivlauncher = unstablePrev.xivlauncher.override {
                steam = unstablePrev.steam.override {
                  # Keep GameMode available in the launcher's Steam runtime.
                  # extraLibraries survives upstream's extraPkgs override.
                  extraLibraries = pkgs: [pkgs.gamemode];
                };
              };
            });
          })
        ];
      };
    };

    homeManager = {
      lib,
      osConfig,
      ...
    }:
      lib.mkIf osConfig.local.ffxiv.enable {
        wayland.windowManager.hyprland.settings.windowrule = lib.mkAfter [
          "float on, match:class ^(XIVLauncher.*)$"
          "border_size 0, match:initial_title ^(FINAL FANTASY XIV)$"
        ];
      };
  };
}

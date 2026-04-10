{
  flake.aspects.gaming._.ffxiv = {
    description = ''
      The acritically acclaimed MMORPG Final Fantasy XIV with an expanded free trial which you can play through the entirety of A Realm Reborn and the award winning Heavensward expansion and also award winning Stormblood expansion up to level 70 for free with no restrictions on playtime.
    '';

    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: let cfg = config.local.ffxiv; in {
      options.local.ffxiv.enable = lib.mkEnableOption "Enables FFXIV via xivlauncher";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.xivlauncher
        ];
      };
    };
  };
}

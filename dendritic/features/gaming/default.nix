{
  flake.aspects.gaming = {
    description = "Collection of aspects with default enablement of games and game providers";

    nixos = {lib, ...}: {
      local = {
        ffxiv.enable = lib.mkDefault true;
        steam.enable = lib.mkDefault true;
      };

      hardware.xone.enable = true; # xbox one accessory drivers

      programs.gamemode.enable = true;
    };
  };
}

{
  flake.aspects = {aspects, ...}: {
    gaming = {
      description = "Collection of aspects with default enablement of games and game providers";

      includes = with aspects.gaming._; [
        steam
        ffxiv
      ];

      nixos = {lib, ...}: {
        local = {
          ffxiv.enable = lib.mkDefault true;
          steam.enable = lib.mkDefault true;
        };

        hardware.xone.enable = true; # xbox one accessory drivers

        programs.gamemode.enable = true;
      };
    };
  };
}

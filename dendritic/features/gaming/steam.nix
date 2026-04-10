{
  flake.aspects.gaming._.steam = {
    description = "The benevolent monopoly game store and installer by valve.";
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.local.steam;
      user = config.local.identity.username;
    in {
      options.local.steam.enable = lib.mkEnableOption "Enables steam";

      config = lib.mkIf cfg.enable {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;

          gamescopeSession.enable = true;
        };

        environment.systemPackages = with pkgs; [
          protonup-ng
        ];

        environment.sessionVariables = {
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${user}/.steam/root/compatibilitytools.d";
        };
      };
    };
  };
}

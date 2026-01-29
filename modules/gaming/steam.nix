{
  pkgs,
  lib,
  config,
  vars,
  ...
}: {
  options.custom.steam.enable = lib.mkEnableOption "enables steam";

  config = lib.mkIf config.custom.steam.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-unwrapped"
        "steam-run"
      ];
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;

      gamescopeSession.enable = true;
    };
    programs.gamemode.enable = true;

    hardware.xone.enable = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      protonup-ng
    ];
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${vars.username}/.steam/root/compatibilitytools.d";
      DXVK_FRAME_RATE = "60";
    };

    services.xserver.videoDrivers = ["amdgpu"]; # Also for wayland
  };
}

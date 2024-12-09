{
  pkgs,
  lib,
  config,
  myvars,
  ...
}:
with myvars; {
  options = {
    steam.enable = lib.mkEnableOption "enables steam";
  };

  config = lib.mkIf config.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;

      gamescopeSession.enable = true;
    };
    programs.gamemode.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      protonup
    ];
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
      DXVK_FRAME_RATE = "60";
    };

    services.xserver.videoDrivers = ["amdgpu"]; # Also for wayland
  };
}

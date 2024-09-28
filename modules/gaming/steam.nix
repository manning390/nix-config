{
  pkgs,
  myvars,
  ...
}:
with myvars; {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;

    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    protonup
    xivlauncher
  ];
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
    DXVK_FRAME_RATE = "60";
  };

  services.xserver.videoDrivers = ["amdgpu"]; # Also for wayland
}

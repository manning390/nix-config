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

      extraPackages = [pkgs.amdvlk];
      extraPackages32 = [pkgs.driversi686Linux.amdvlk];
    };
    hardware.amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
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

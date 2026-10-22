{
  flake.aspects.wezterm = {
    description = "Terminal emulator and multiplexer, typically used on windows.";
    homeManager = {
      lib,
      osConfig,
      pkgs,
      ...
    }: let
      windowsUser = osConfig.local.wsl.windowsUser;
      windowsConfig = "/mnt/c/Users/${windowsUser}/.wezterm.lua";
    in {
      home.packages = with pkgs; [
        wezterm.terminfo
      ];

      home.activation.installWezTermWindowsConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.coreutils}/bin/install -D -m 0644 ${./wezterm.lua} ${lib.escapeShellArg windowsConfig}
      '';
    };
  };
}

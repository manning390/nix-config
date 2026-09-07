{
  flake.aspects.wezterm = {
    description = "Terminal emulator and multiplexer, typically used on windows.";
    # nixos = {
    #   config,
    #   lib,
    #   pkgs,
    # }: let
    #   cfg = config.local.wezterm;
    # in {
    #   options.local.wezterm = {
    #     enable = lib.mkEnableOption "Enable wezterm";
    #     install = lib.mkEnableOption "Install wezterm as a package";
    #   };
    # };
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        wezterm.terminfo
      ];
    };
  };
}

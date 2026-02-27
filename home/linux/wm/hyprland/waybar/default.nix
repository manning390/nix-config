{
  pkgs,
  lib,
  config,
  ...
}: {
  options.local.wm.waybar.enable =
    lib.mkEnableOption "enables waybar"
    // {
      default = false;
    };

  config = lib.mkIf config.local.wm.waybar.enable {
    home.packages = with pkgs; [
      (pkgs.waybar.overrideAttrs (oldAttrs: {mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];})) # Bar
      glxinfo # GPU info
      bc # calculator
    ];

    xdg.configFile."waybar" = {
      recursive = true;
      source = ./.;
    };
  };
}

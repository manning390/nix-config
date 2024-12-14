{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    waybar.enable = lib.mkEnableOption "enables waybar";
  };

  config = lib.mkIf config.waybar.enable {
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

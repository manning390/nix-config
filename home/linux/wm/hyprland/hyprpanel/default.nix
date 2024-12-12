{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    hyprpanel.enable = lib.mkEnableOption "enables hyprpanel";
  };

  config = lib.mkIf config.hyprpanel.enable {
    nixpkgs.overlays = [
      inputs.hyprpanel.overlay
    ];

    home.packages = with pkgs; [
      hyprpanel
    ];
    home.file.".config/ags/config.js".source = ./config.json;

    wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
      "uwsm app -- hyprpanel"
    ];
  };
}

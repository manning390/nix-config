{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  options.custom.wm.hyprpanel.enable = lib.mkEnableOption "enables hyprpanel" // {default = true;};

  config = lib.mkIf config.custom.wm.hyprpanel.enable {
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

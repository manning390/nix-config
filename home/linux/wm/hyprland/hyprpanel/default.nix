{
  lib,
  config,
  osConfig,
  ...
}: {
  options.local.wm.hyprpanel.enable = lib.mkEnableOption "enables hyprpanel" // {default = true;};

  config = lib.mkIf config.local.wm.hyprpanel.enable {
    programs.hyprpanel.enable = true;

    home.file.".config/hyprpanel/config.js".source = ./${osConfig.networking.hostName}.config.json;

    wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
      "uwsm app -- hyprpanel"
    ];
  };
}

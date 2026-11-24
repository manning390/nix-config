# Render the effective (merged) bindings, including shared and host-specific
# bindings. Keep presentation logic out of the actual keybinding definitions.
{
  flake.modules.homeManager.caelestia-keybinding-reference = {
    config,
    lib,
    osConfig,
    pkgs,
    ...
  }: let
    settings = config.wayland.windowManager.hyprland.settings;
    dwindle = osConfig.local.wm.hyprland.layout == "dwindle";
    directions = {
      l = "left";
      d = "down";
      u = "up";
      r = "right";
    };

    commandDescriptions = {
      "app2unit -s a kitty" = "Terminal (Kitty)";
      "hyprctl kill" = "Interactive kill mode (not ordinary close)";
      "playerctl play-pause" = "Media play/pause";
      "playerctl next" = "Next media track";
      "playerctl previous" = "Previous media track";
      "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" = "Volume +5%";
      "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" = "Volume -5%";
      "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" = "Toggle output mute";
      "brightnessctl set 5%+" = "Brightness +5%";
      "brightnessctl set 5%-" = "Brightness -5%";
    };

    describeAction = {
      kind,
      dispatcher,
      arguments,
      fallback,
    }: let
      actions = {
        killactive = "Close active window";
        exit = "Exit compositor immediately";
        togglefloating = "Toggle floating";
        pseudo = "Toggle pseudotiling";
        fullscreen = "Toggle fullscreen";
        focuscurrentorlast = "Previous/current window";
        movefocus = "Focus ${directions.${arguments} or arguments}";
        movewindow =
          if kind == "bindm"
          then "Drag window"
          else "Move window ${directions.${arguments} or arguments}";
        resizewindow = "Resize window with mouse";
        workspace = "Workspace ${arguments}";
        movetoworkspace = "Move window to workspace ${arguments} and follow";
        layoutmsg =
          if arguments == "togglesplit"
          then "Toggle split direction"
          else "Layout: ${arguments}";
      };
    in
      if dispatcher == "exec"
      then commandDescriptions.${arguments} or arguments
      else if dispatcher == "global" && arguments == "caelestia:lock"
      then "Lock screen"
      else actions.${dispatcher} or fallback;

    flagNotes = flags:
      lib.optionals (lib.hasInfix "e" flags) ["repeats"]
      ++ lib.optionals (lib.hasInfix "l" flags) ["also while locked"]
      ++ lib.optionals (lib.hasInfix "r" flags) ["on release"];

    formatBinding = kind: binding: let
      fields = map lib.trim (lib.splitString "," binding);
      modifiers = lib.replaceStrings ["$mod" " "] ["Super" " + "] (builtins.elemAt fields 0);
      key = builtins.elemAt fields 1;
      chord = "${modifiers}${lib.optionalString (modifiers != "") " + "}${key}";
      flags = lib.removePrefix "bind" kind;
      notes = flagNotes flags;

      # bindd (and variants) already has a human-readable description. For
      # historical bindings, translate known dispatchers/commands instead.
      description =
        if lib.hasInfix "d" flags
        then builtins.elemAt fields 2
        else
          describeAction {
            inherit kind;
            dispatcher = builtins.elemAt fields 2;
            arguments = lib.concatStringsSep " " (lib.drop 3 fields);
            fallback = lib.concatStringsSep " " (lib.drop 2 fields);
          };
      annotation = lib.optionalString (notes != []) " (${lib.concatStringsSep "; " notes})";
    in "${chord}  —  ${description}${annotation}";

    bindingTypes = lib.filter (
      name: lib.hasPrefix "bind" name && builtins.isList settings.${name}
    ) (builtins.attrNames settings);

    header = ''
      DESKTOP KEYBINDINGS — typed symbols, not QWERTY keycaps
      Super + ? opens this reference; Escape closes it. Search to filter.
      Super alone opens the application launcher on release (not after a chord).
      M / N / E / I = left / down / up / right; Shift moves windows.
      Super + Shift + number moves AND follows the window.
      Super + Shift + P pseudotiles: preferred-size window inside its tile.
      Recording sound = desktop/output audio, not microphone.
      Plain Ctrl+P stays with applications. No clipboard/recent-file tracking.

    '';

    resizeHelp = ''

      RESIZE MODE (Super + R)
      M / Left: narrower; I / Right: wider; E / Up: shorter; N / Down: taller.
      Escape or Enter: return to normal bindings.
    '';
  in {
    config = lib.mkIf config.local.desktop.caelestia.enable {
      xdg.configFile."caelestia/keybindings.txt".source = pkgs.writeText "desktop-keybindings.txt" (
        header
        + lib.concatMapStringsSep "\n" (
          kind: lib.concatMapStringsSep "\n" (formatBinding kind) settings.${kind}
        )
        bindingTypes
        + lib.optionalString dwindle resizeHelp
      );
    };
  };
}

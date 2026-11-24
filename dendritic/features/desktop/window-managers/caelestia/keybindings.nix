{
  flake.modules.homeManager.caelestia-keybindings = {
    config,
    lib,
    osConfig,
    pkgs,
    ...
  }: let
    cfg = config.local.desktop.caelestia;
    dwindle = osConfig.local.wm.hyprland.layout == "dwindle";
    screenshots = config.home.sessionVariables.CAELESTIA_SCREENSHOTS_DIR;

    areaScreenshot = pkgs.writeShellApplication {
      name = "area-screenshot";
      runtimeInputs = with pkgs; [python3 grim slurp wl-clipboard libnotify];
      text = ''
        export CAELESTIA_SCREENSHOTS_DIR=${lib.escapeShellArg screenshots}
        exec python3 ${./area-screenshot.py} "$@"
      '';
    };
    windowPicker = pkgs.writeShellApplication {
      name = "window-picker";
      runtimeInputs = with pkgs; [python3 fuzzel libnotify];
      text = ''
        exec python3 ${./window-picker.py} "$@"
      '';
    };

    showReference = lib.concatStringsSep " " [
      "${pkgs.fuzzel}/bin/fuzzel --dmenu"
      "--width=100 --lines=24 --font='monospace:size=11'"
      "--prompt='Keybindings (Escape closes)> '"
      "< ${lib.escapeShellArg "${config.xdg.configHome}/caelestia/keybindings.txt"}"
      "> /dev/null"
    ];
  in {
    config = lib.mkIf cfg.enable {
      home.sessionVariables.FILE_BROWSER = lib.mkDefault "yazi";

      wayland.windowManager.hyprland = {
        settings = {
          # Historical lock and media keys.
          bind = lib.mkAfter [
            "$mod, L, global, caelestia:lock"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPrev, exec, playerctl previous"
          ];

          bindd =
            [
              # Shell and desktop utilities
              "$mod, C, Clear notifications, global, caelestia:clearNotifs"
              "$mod SHIFT, C, Copy selected colour, exec, hyprpicker -a"
              "CTRL ALT, Delete, Session menu, global, caelestia:session"
              "$mod CTRL, B, Sidebar, global, caelestia:sidebar"
              "$mod, K, Toggle shell panels, global, caelestia:showall"
              "$mod, period, Emoji picker, exec, caelestia emoji -p"

              # Screenshots: selected area / immediate save / focused monitor
              ", Print, Copy area and offer Save, exec, ${areaScreenshot}/bin/area-screenshot"
              "SHIFT, Print, Copy and save area, exec, ${areaScreenshot}/bin/area-screenshot --save"
              "$mod, Print, Copy focused monitor and offer Open or Save, exec, monitor-screenshot"
              "$mod SHIFT, S, Frozen area to clipboard, global, caelestia:screenshotFreezeClip"
              "$mod SHIFT ALT, S, Annotate area in Swappy, global, caelestia:screenshot"

              # Recording toggles; sound captures output audio, not microphone
              "CTRL ALT, R, Toggle focused-monitor recording without audio, exec, caelestia record"
              "$mod ALT, R, Toggle focused-monitor recording with output audio, exec, caelestia record -s"

              # Existing file browser and searchable running-window picker
              "$mod, P, File browser, exec, app2unit -s a kitty --directory ${lib.escapeShellArg config.home.homeDirectory} -e ${lib.escapeShellArg config.home.sessionVariables.FILE_BROWSER}"
              "$mod, space, Running-window picker, exec, ${windowPicker}/bin/window-picker"

              # Super+?: Hyprland matches the unshifted slash symbol on US/Colemak.
              "$mod SHIFT, slash, Keybinding reference - Super plus question mark, exec, ${showReference}"
            ]
            ++ lib.optional dwindle "$mod, R, Enter resize mode - Escape or Enter exits, submap, resize";

          # A normal release/exec binding can be shadowed by other Super chords;
          # a global binding cannot. Support both left and right Super.
          bindrd = map (
            key: "$mod, ${key}, Application launcher on Super alone, exec, caelestia shell drawers toggle launcher"
          ) ["Super_L" "Super_R"];

          # Preserve repeating/locked volume keys and host-specific brightness.
          bindel = lib.mkAfter ([
              ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ]
            ++ lib.optionals cfg.showBrightness [
              ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
              ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
            ]);
          bindl = lib.mkAfter [
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ];
        };

        # Resize mode is deliberately dwindle-only. Preserve M/N/E/I directions
        # and their arrow aliases; always return to the default submap afterward.
        extraConfig = lib.optionalString dwindle ''
          submap = resize
          binde = , M, resizeactive, -30 0
          binde = , left, resizeactive, -30 0
          binde = , N, resizeactive, 0 30
          binde = , down, resizeactive, 0 30
          binde = , E, resizeactive, 0 -30
          binde = , up, resizeactive, 0 -30
          binde = , I, resizeactive, 30 0
          binde = , right, resizeactive, 30 0
          bind = , Escape, submap, reset
          bind = , Return, submap, reset
          submap = reset
        '';
      };

      home.packages = [areaScreenshot windowPicker];
    };
  };
}

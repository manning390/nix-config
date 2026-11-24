{
  flake.modules.homeManager.caelestia-screenshot-reminder = {
    config,
    lib,
    pkgs,
    ...
  }: let
    screenshots = config.home.sessionVariables.CAELESTIA_SCREENSHOTS_DIR;
    reminder = pkgs.writeShellApplication {
      name = "screenshot-reminder";
      runtimeInputs = with pkgs; [coreutils findutils libnotify util-linux];
      text = ''
        screenshots=${lib.escapeShellArg screenshots}
        state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/caelestia"
        cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/caelestia"
        mkdir -p -- "$screenshots" "$state_dir" "$cache_dir"

        # Login and directory-change checks may run together.
        exec 9>"$cache_dir/screenshot-reminder.lock"
        flock -n 9 || exit 0

        # Count images without parsing filenames (which can contain newlines).
        count=$(find -L "$screenshots" -maxdepth 1 -type f \
          \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
          -printf '.' | wc -c)

        state_file="$state_dir/screenshot-reminder.state"
        previous_count=""
        notification_id=""
        if [[ -f "$state_file" ]]; then
          read -r previous_count notification_id < "$state_file" || true
        fi

        # Replace the existing reminder, rather than accumulating notifications.
        if (( count >= 50 )) && [[ "''${1:-}" == "--login" || "$count" != "$previous_count" ]]; then
          options=(--print-id)
          if [[ "$notification_id" =~ ^[0-9]+$ ]]; then
            options+=("--replace-id=$notification_id")
          fi
          notification_id=$(notify-send --app-name=screenshot-reminder "''${options[@]}" \
            "Organize screenshots" \
            "$count screenshots in your Screenshots folder. Move keepers elsewhere and remove captures you no longer need." \
            || true)
        fi

        # Do not source shell code from the state file; store only the count and ID.
        temporary=$(mktemp "$state_dir/screenshot-reminder.XXXXXX")
        trap 'rm -f -- "$temporary"' EXIT
        printf '%s %s\n' "$count" "$notification_id" > "$temporary"
        mv -- "$temporary" "$state_file"
      '';
    };
    command = "${reminder}/bin/screenshot-reminder";
  in {
    config = lib.mkIf config.local.desktop.caelestia.enable {
      home.packages = [reminder];

      # No periodic timer: check at session start and on directory changes.
      wayland.windowManager.hyprland.settings.exec-once = ["${command} --login"];
      systemd.user.services.screenshot-reminder = {
        Unit = {
          Description = "Remind about screenshots awaiting organization";
          PartOf = ["graphical-session.target"];
          After = ["caelestia.service"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = command;
        };
      };
      systemd.user.paths.screenshot-reminder = {
        Unit.PartOf = ["graphical-session.target"];
        Path = {
          PathChanged = screenshots;
          Unit = "screenshot-reminder.service";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}

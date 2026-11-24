{
  flake.modules.homeManager.caelestia-monitor-screenshot = {
    config,
    lib,
    pkgs,
    ...
  }: let
    screenshots = config.home.sessionVariables.CAELESTIA_SCREENSHOTS_DIR;
    cli = config.programs.caelestia.cli.package;
    monitorScreenshot = pkgs.writeShellApplication {
      name = "monitor-screenshot";
      runtimeInputs = with pkgs; [coreutils util-linux libnotify cli];
      text = ''
        export CAELESTIA_SCREENSHOTS_DIR=${lib.escapeShellArg screenshots}
        cache="''${XDG_CACHE_HOME:-$HOME/.cache}/caelestia"
        mkdir -p -- "$cache"

        # The pinned CLI uses second-resolution filenames. Hold the lock through
        # notification dismissal/Save. --close prevents clipboard daemons and other
        # descendants from inheriting the lock and keeping it held afterward.
        if flock --nonblock --conflict-exit-code 75 --close \
          "$cache/monitor-screenshot.lock" caelestia screenshot; then
          exit 0
        else
          status=$?
        fi

        if (( status == 75 )); then
          notify-send --app-name=monitor-screenshot "Monitor capture pending" \
            "Dismiss or act on the previous monitor screenshot first." || true
          exit 0
        fi
        exit "$status"
      '';
    };
  in {
    config = lib.mkIf config.local.desktop.caelestia.enable {
      home.packages = [monitorScreenshot];
    };
  };
}

{
  pkgs,
  config,
  lib,
  isLaptop,
  ...
}: {
  options.custom.laptop.enable =
    lib.mkEnableOption "enables additional laptop settings"
    // {
      default = isLaptop;
    };
  config = lib.mkIf config.custom.laptop.enable {

      # Enable upower service
      services.upower.enable = true;

      # # Create a script to fetch battery percentage
      # environment.systemPackages = with pkgs; [
      #   (writeShellScriptBin "get-battery-percentage" ''
      #     upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d '%'
      #   '')
      # ];
      #
      # # Set up a user service to update the environment variable
      # systemd.user.services.update-battery-percentage = {
      #   description = "Update battery percentage for HyprPanel";
      #   script = ''
      #     export POWER_LEVEL=$(get-battery-percentage)
      #     systemctl --user import-environment POWER_LEVEL
      #   '';
      #   serviceConfig = {
      #     Type = "oneshot";
      #   };
      # };
      #
      # systemd.user.timers.update-battery-percentage = {
      #   wantedBy = [ "timers.target" ];
      #   timerConfig = {
      #     OnBootSec = "1m";
      #     OnUnitActiveSec = "1m";
      #   };
      # };
  };
}

{
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
    services.tlp = {
      enable = true;
      setting = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
      };
    };
  };
}

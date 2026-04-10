{
  flake.aspects.hdd-spindown = {
    description = "HDD spin-down power management for drives not needed at boot";

    nixos = {config, pkgs, lib,...}: let
      cfg = config.local.hdd-spindown;
    in {
      options.local.hdd-spindown = {
        enable = lib.mkEnableOption "HDD spin-down power management";

      };
      environment.systemPackages = with pkgs; [ hdparm ];
    };
  };
  # Experiment, monitor drives

}

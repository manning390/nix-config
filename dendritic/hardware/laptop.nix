{
  flake.aspects.laptop = {
    description = "Laptop related settings";
    nixos = {
      config,
      lib,
      ...
    }: {
      services.upower.enable = true;
      services.power-profiles-daemon = {
        enable = true;
      };
      services.logind.settings.Login = {
        HandleLidSwitch = lib.mkDefault "suspend";
        HandleLidSwitchExternalPower = lib.mkDefault "suspend";
        HandleLidSwitchDocked = lib.mkDefault "ignore";
        # Caelestia handles idle timers for the graphical session.
        IdleAction = lib.mkDefault "ignore";
      };
    };
  };
}

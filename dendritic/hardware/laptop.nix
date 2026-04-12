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
    };
  };
}

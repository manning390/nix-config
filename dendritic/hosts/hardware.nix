{self, ...}: {
  flake.aspects.hardware = hostname: {
    description = "Parametric aspect wrapper for hardware configurations.";
    # This reduces multiple imports styles across configruations and can just reference the hardware output directly.
    # When writing a hardware module, write to this spec:
    # flake.modules.nixos.hardware-myhostname
    nixos = {
      imports = [self.modules.nixos."hardware-${hostname}"];
    };
  };
}

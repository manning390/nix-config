{self, ...}: {
  flake.aspects.hardware = hostname: {
    description = "Parametric aspect for hardware configurations.";
    nixos = {lib,...}: {
      # Hardware configurations Wrapper
      # This reduces multiple imports styles across configruations
      # Can just reference the hardware output directly.
      imports = [self.modules.nixos."hardware-${hostname}"];
      # When writing a hardware module, write to this spec:
      # flake.modules.nixos.hardware-myhostname

      options.local = {
        hardware = {
          monitors = lib.mkOption {
            type = lib.types.attrsOf lib.types.singleLineStr;
            default = {};
            description = "
              Attribute set of monitor hardware ids and settings as values.
              [hardware name] => resolution@frequency,positioning,scale
              list available hardware with `hyprland monitors all` ipc command
            ";
            example = {
              "HDMI-0" = "2560x1440@144,0x0,1";
              "HDMI-1" = "2560x1440@144,2560x0,1";
            };
          };
        };
      };
    };
  };
}

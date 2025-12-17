{
  config,
  lib,
  ...
}: {
  options.custom.keyd.enable = lib.mkEnableOption "enables keyd remaps";
  config = lib.mkIf config.custom.keyd.enable {
    services.keyd = {
      enable = true;
      keyboards.true = {
        ids = ["*"];
        settings.main = {
          capslock = "overload(control, esc)";
        };
      };
    };
  };
}

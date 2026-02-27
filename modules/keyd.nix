{
  config,
  lib,
  ...
}: {
  options.local.keyd.enable = lib.mkEnableOption "enables keyd remaps";
  config = lib.mkIf config.local.keyd.enable {
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

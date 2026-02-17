{
  lib,
  config,
  vars,
  ...
}: let 
  cfg = config.custom.wsl;
in {
  options.custom.wsl = {
    enable = lib.mkEnableOption "enables WSL";
  };

  config = lib.mkIf cfg.enable {
    wsl.enable = true;
    wsl.defaultUser = vars.username;
  };
}

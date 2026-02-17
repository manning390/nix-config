{
  lib,
  config,
  vars,
  ...
}: let 
  cfg = config.local.wsl;
in {
  options.local.wsl = {
    enable = lib.mkEnableOption "enables WSL";
  };

  config = lib.mkIf cfg.enable {
    wsl.enable = true;
    wsl.defaultUser = vars.username;
  };
}

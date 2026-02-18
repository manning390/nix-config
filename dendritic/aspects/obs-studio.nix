{
  flake.aspects.obs-studio = {
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }: let
      cfg = config.local.obs-studio;
    in {
      options.local.obs-studio = {
        enable = lib.mkEnableOption "enables obs studio";
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          (pkgs.wrapOBS {
            plugins = with pkgs.obs-studio-plugins; [
              wlrobs
              obs-background-removal
              obs-pipewire-audio-capture
            ];
          })
        ];
      };
    };
  };
}

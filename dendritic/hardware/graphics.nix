{
  flake.aspects.hardware._.graphics = {
    nixos = {
      config,
      lib,
      ...
    }: let
      cfg = config.local.hardware.gpu;
    in {
      options.local.hardware.gpu = {
        enable = lib.mkEnableOption "Enable GPU graphics configurations";
        team = lib.mkOption {
          type = lib.types.enum ["amd" "nvidia" "red" "green"];
          default = "amd";
          description = "Which manufacturer is the graphics card for drivers. Colors are aliases";
        };
      };
      config = lib.mkIf cfg.enable (lib.mkMerge [
        {
          # Hardware acceleration drivers
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };
        }

        # Driver installations!!
        # videoDrivers = [] will try in order until combatible one found
        # Also for wayland
        # Don't combined free with proprietary ones

        (lib.mkIf (cfg.team == "amd" || cfg.team == "red") {
          # https://wiki.nixos.org/wiki/AMD_GPU
          services.xserver.videoDrivers = ["amdgpu"];
        })
        (lib.mkIf (cfg.team == "nvidia" || cfg.team == "green") {
          # https://wiki.nixos.org/wiki/NVIDIA
          # Unfree nvidia* https://www.nvidia.com/en-us/drivers/unix/
          services.xserver.videoDrivers = ["nvidia"];
          hardware.nvidia.open = lib.mkDefault true;
        })
      ]);
    };
  };
}

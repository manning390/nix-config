{
  flake.aspects = {aspects,...}: {
    homelab = {
      description = "Entrypoint for homelab configurations.";

      includes = with aspects; [samba services];

      nixos = {config,lib,...}: let
        cfg = config.homelab;
      in {
        options.homelab = {
          enable = lib.mkEnableOption "The homelab services and configuration variables";
          mounts.fast = lib.mkOption {
            default = "/fast";
            type = lib.types.path;
            description = "Path to the 'fast' tier mount";
          };
          mounts.slow = lib.mkOption {
            default = "/bulk";
            type = lib.types.path;
            description = "Path to the 'slow' tier mount";
          };
          user = lib.mkOption {
            default = "share";
            type = lib.types.str;
            description = ''
              User to run the homelab services as
            '';
          };
          group = lib.mkOption {
            default = "share";
            type = lib.types.str;
            description = ''
              Group to run the homelab services as
            '';
          };
          baseDomain = lib.mkOption {
            default = "";
            type = lib.types.str;
            description = ''
              Base domain name to be used to access the homelab services via Caddy reverse proxy
            '';
          };
        };

        config = lib.mkIf cfg.enable {
          users = {
            groups.${cfg.group} = {
              gid = 993;
            };
            users.${cfg.user} = {
              uid = 994;
              isSystemUser = true;
              group = cfg.group;
            };
          };
        };
      };
    };
  };
}

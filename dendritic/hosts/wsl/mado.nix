{config, ...}: let
  hostname = "mado";
  user = "pch";
in {
  local.hosts.${hostname} = {
    type = "wsl";
    stateVersion = "24.11";
  };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      includes = with aspects; [
        base
        (homeManager._.users user)
        nix-index
      ];

      nixos = {
        imports = [
          ../../../modules/common.nix
          ../../../modules/shells.nix
        ];

        local = {
          shells = {
            systemShell = "fish";
            userShell = "fish";
          };
          ssh = {
            enable = true;
            users = {
              "${user}" = {
                connectTo = ["pch@sentry" "pch@glaciem" "ruby@ruby"];
                extraHosts = {
                  "github.com" = {
                    hostname = "github.com";
                    user = "git";
                    identityFile = "github";
                  };
                };
              };
            };
          };
        };

        environment.sessionVariables = {
          COLEMAK = "1";
          NIXCONFIG = "/home/${user}/Code/nix/nix-config";
        };
      };

      homeManager = {}; # Required for included homeMager modules to be imported
    };
  };
}

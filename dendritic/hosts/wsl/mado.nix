let
  hostname = "mado";
  user = "pch";
in {
  local.hosts.${hostname} = {
    type = "wsl";
    stateVersion = "24.11";
  };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      description = "WSL Instance on windows home machine";
      includes = with aspects; [
        base
        (homeManager._.users user)
        nix-index
      ];

      nixos = {config,...}: {
        local = {
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
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
                  "glaciem.git" = {
                    hostname = config.local.lan.hosts.glaciem;
                    user = "git";
                    identityFile = "${user}@${hostname}";
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

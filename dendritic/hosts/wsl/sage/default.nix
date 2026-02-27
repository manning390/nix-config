{self, config, ...}: let
  hostname = "sage";
  user = config.local.identity.username;
in {
  local.hosts.${hostname} = {
    type = "wsl";
    stateVersion = "25.11";
  };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      includes = with aspects; [
        base
        (homeManager._.users user)
        docker
      ];

      nixos = {
        config,
        pkgs,
        ...
      }: {
        imports = [
          ../../../../modules/common.nix
          ../../../../modules/shells.nix
        ];

        local = {
          shells = {
            systemShell = "fish";
            userShell = "fish";
          };
          git.includeFile = config.sops.templates."gitconfig".path;
        };

        environment.sessionVariables = {
          COLEMAK = "1";
          NIXCONFIG = "/home/${user}/Code/nix/nix-config";
        };

        environment.shellAliases = {
          whostname = "echo 'AP1H85254WLR' | clip.exe";
        };
        sops = let
          sopsFile = ./secrets/sage.yaml;
          owner = user;
          group = "users";
          mode = "0600";
        in {
          secrets = {
            "npm/npmrc" = {
              inherit sopsFile owner group mode;
              path = "/home/${user}/.npmrc";
            };
            "workemail" = {inherit sopsFile owner group mode;};
            "userProfile" = {
              inherit sopsFile owner group mode;
              path = "/home/${user}/.profile";
            };
          };
          templates."gitconfig" = {
            inherit owner group mode;
            content = ''
              [user]
                  email = ${config.sops.placeholder.workemail}
            '';
          };
        };
      };

      homeManager = {
        imports = [
          ./_daily_logging.nix
        ];
      };
    };
  };
}

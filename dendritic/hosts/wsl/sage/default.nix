let
  hostname = "sage";
  user = "pch";
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
        jira
        nix-index
      ];

      nixos = {
        config,
        ...
      }: {
        imports = [
          (import ./_sops.nix {inherit user;}) # Passing some scope, this file is special
        ];

        local = {
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
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
      };

      homeManager = {
        imports = [
          ./_daily_logging.nix
        ];
        home.sessionVariables = {
          PATH = "$HOME/.local/bin:$PATH";
        };
      };
    };
  };
}

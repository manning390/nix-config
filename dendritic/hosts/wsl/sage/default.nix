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
        herdr
      ];

      nixos = {
        config,
        pkgs,
        ...
      }: {
        imports = [
          (import ./_sops.nix {inherit user;}) # Passing some scope, this file is special
        ];

        local = {
          kitty.enable = false;
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
          git.includeFile = config.sops.templates."gitconfig".path;
        };

        environment.systemPackages = with pkgs; [
          codex
          bubblewrap
          gh
          python3
          gcc
          gnumake
        ];
        systemd.tmpfiles.rules = [
          "L+ /usr/bin/bash - - - - /run/current-system/sw/bin/bash"
        ];

        environment.sessionVariables = {
          COLEMAK = "1";
          NIXCONFIG = "/home/${user}/Code/nix/nix-config";
        };

        environment.shellAliases = {
          whostname = "echo 'AP1H85254WLR' | clip.exe";
        };
      };

      homeManager = {pkgs, ...}: {
        imports = [
          ./_daily_logging.nix
        ];
        home.sessionVariables = {
          TERM = "wezterm";
          PATH = "$HOME/.local/bin:$PATH";
        };
      };
    };
  };
}

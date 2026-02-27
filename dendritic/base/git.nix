top: let
  identity = top.config.local.identity;
in {
  flake.aspects = {
    git = {
      nixos = {
        pkgs,
        lib,
        config,
        ...
      }: let
        cfg = config.local.git;
      in {
        options.local.git = {
          enable = lib.mkEnableOption "Enables git";
          email = lib.mkOption {
            type = lib.types.str;
            default = identity.email;
            description = "User level default email";
          };
          includeFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "
              Optional gitconfig fragment incuded after everything for global overrides.
              Ensure it follows git config INI format.
            ";
          };
          server = {
            enable = lib.mkEnableOption "Enable hosting git repositories";
            directory = lib.mkOption {
              type = lib.types.string;
              default = "/home/git";
              description = "Where will the git repositoies be saved";
            };
            authorizedKeys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
            };
          };
        };

        config = lib.mkMerge [
          (lib.mkIf cfg.enable {
            environment.systemPackages = [pkgs.git];
          })
          (lib.mkIf (cfg.enable && cfg.server.enable) {
            users.users.git = {
              isSystemUser = true;
              group = "git";
              home = cfg.server.directory;
              createHome = true;
              shell = "${pkgs.git}/bin/git-shell";
              openssh.authorizedKeys.keys = cfg.server.authorizedKeys;
            };
            users.groups.git = {};
            services.openssh = {
              enable = true;
              extraConfig = ''
                Match user git
                  AllowTcpForwarding no
                  AllowAgentForwarding no
                  PasswordAuthentication no
                  PermitTTY no
                  X11Forwarding no
              '';
            };
            environment.systemPackages = [
              (pkgs.writeShellScriptBin "create-git-repo"
                /*
                bash
                */
                ''
                  set -euo pipefail

                  REPO_NAME="''${1:?Usage: create-git-repo <repo-name> [description]}"
                  DESCRIPTION="''${2:-}"
                  GIT_DIR="${cfg.server.directory}/$REPO_NAME.git"

                  if [ -d "$GIT_DIR" ]; then
                    echo "Error: Repository already exists at $GIT_DIR" >&2
                    exit 1
                  fi

                  echo "Creating bare git repository: $REPO_NAME"
                  ${pkgs.git}/bin/git init --bare "$GIT_DIR"
                  ${pkgs.coreutils}/bin/chown -R git:git "$GIT_DIR"
                  ${pkgs.coreutils}/bin/chmod -R 750 "$GIT_DIR"

                  if [ -n "$DESCRIPTION" ]; then
                    echo "$DESCRIPTION" > "$GIT_DIR/description"
                  fi

                  echo "Repository created at: $GIT_DIR"
                  echo "Clone with: git clone git@${config.networking.hostName}:$REPO_NAME.git"
                  echo "Set remote with: git remote add origin git@${config.networking.hostName}:$REPO_NAME.git"
                '')
            ];
          })
        ];
      };

      homeManager = {
        lib,
        osConfig,
        ...
      }: let
        cfg = osConfig.local.git;
      in
        lib.mkIf cfg.enable {
          programs.git = {
            enable = true;

            includes = lib.optionals (cfg.includeFile != null) [
              {path = cfg.includeFile;}
            ];

            settings = {
              user.name = identity.fullName;
              user.email = cfg.email;
              init.defaultBranch = "main";
              pull.rebase = false;
              push.autoSetupRemote = true;
              core.editor = "nvim";
              fetch.prune = true;
              github.user = "manning390";

              alias = let
                bash = c: ''!bash -c '${c}' ''; # Wraps commands in bash
              in {
                st = "status";
                ci = "commit";
                ca = "commit --amend";
                co = "checkout";
                cp = "cherry-pick";
                br = "branch";
                vi = "!nvim -c 'G'"; # Fugitive in vim

                last = "log -1";
                unstage = "reset HEAD --";
                tree = "log --all --graph --decorate --oneline";
                hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";

                # Complex, Require bash wrapping
                # Copy branch name, requires copy
                bc = bash "git branch --show-current | tr -d '\n' | copy";
                by = "bc";
                # Move a branch
                mv = bash ''git branch -m "$1" "$2" && [ $(git ls-remote --heads origin "$1" | wc -l) = 1 ] && git push origin ":$1" "$2"'';
                # Make a pr branch under pr number
                pr = bash "git fetch origin pull/$1/head:pr-$1 && git checkout pr-$1";
                # Search for a branch
                fd = bash ''branch=$(git branch -a | grep -v remotes | grep "$1" | head -n1 | cut -c3-); [ -n $branch ] && git checkout "$branch"'';
                yeet = bash "git add . && git commit"; # Add, commit
                yt = "yeet";
                yoink = bash ''git pull origin $(git branch --show-current | tr -d '\n')''; # Get remote head
                yk = "yoink";
                # add, commit, force push
                yolo = bash ''msg=$(curl -s https://whatthecommit.com/index.txt); git add . && git commit -m "$msg -yolo" -y && git push origin HEAD -f'';
                # git pull origin main
                rent = bash ''main=$(git branch -l master main | sed 's/^* //' | head -1); [ -n $main ] && git pull origin $main'';
                # Delete all branches locally but main or master
                cull = bash "git for-each-ref --format '%(refname:short)' refs/heads | grep -v 'master|main' | xargs git branch -D";
                clear = bash ''clear; echo "Good job."'';
              };
            };
          };
        };
    };
  };
}

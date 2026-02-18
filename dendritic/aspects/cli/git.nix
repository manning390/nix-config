{
  flake.aspects.git = {
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }: let
      cfg = config.local.git;
    in {
      options.local.git = {
        enable = lib.mkEnable "Enables git";
        email = lib.mkOption {
          type = lib.types.str;
          default = config.local.identity.email;
          description = "User level default email";
        };
        server = {
          enable = lib.mkEnable "Enable hosting git repositories";
          directory = lib.mkOption {
            type = lib.types.string;
            default = "/home/git";
            description = "Where will the git repositoies be saved";
          };
          authorizedKeys = {
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
      config,
      ...
    }: let
      cfg = config.local.git;
    in
      lib.mkIf cfg.enable {
        programs.git = {
          enable = true;

          settings = {
            user.name = config.local.identity.fullName;
            user.email = cfg.email;
            init.defaultBranch = "main";
            pull.rebase = false;
            push.autoSetupRemote = true;

            alias = {
              st = "status";
              ci = "commit";
              co = "checkout";
              br = "branch";
              cp = "cherry-pick";
              last = "log -1";
              unstage = "reset HEAD --";
              ca = "commit --amend";
              tree = "log --all --graph --decorate --oneline";
              mv = "!branchmv() { git branch -m $1 $2; if [[ `git ls-remote --heads origin $1 | wc -l` -eq 1 ]]; then git push origin :$1; git push origin $2; fi }; branchmv";

              vi = "!nvim -c 'G'"; # Fugitive in vim
              bc = "!git branch --show-current | tr -d '\n' | pbcopy"; # Copy branch name
              by = "bc";
              fd = "!f(){git branch -a | grep -v remotes | grep $1 | head -n 1 | xargs git checkout; };f"; # Partial search for branch name

              yeet = "!git add . && git commit"; # Add, commit
              yt = "yeet";
              yoink = "!git pull origin $(git branch --show-current | tr -d '\n')"; # Get remote head
              yk = "yoink";

              yolo = "!git add . && git commit -m \"$(curl -s https://whatthecommit.com/index.txt) -yolo\"  && git push origin HEAD -f"; # add, commit, force push
              rent = "!git pull origin $(git branch -l master main | sed 's/^* //')"; # git origin pull main
              cull = "!git for-each-ref --format '%(refname:short)' refs/heads | grep -v 'master\\|main' | xargs git branch -D"; # Delete all branches locally but main or master

              clear = "!clear; echo \"Good job.\"";
            };
          };
        };
      };
  };
}

{
  pkgs,
  lib,
  vars,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = vars.userfullname;
        email = lib.mkDefault vars.useremail;
      };
      init.defaultBranch = "main";
      pull.rebase = false;

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
}

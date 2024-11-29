{
  pkgs,
  lib,
  myvars,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    userName = myvars.userfullname;
    userEmail = lib.mkDefault myvars.useremail;

    aliases = {
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
      clear = "!clear; echo \"Good job.\"";
      yeet = "!git add . && git commit";
      yolo = "!git add . && git commit -m \"$(curl -s https://whatthecommit.com/index.txt) -yolo\"  && git push origin HEAD -f";
      vi = "!nvim -c 'G'";
    };

    extraConfig = {
      core = {
        defaultBranch = "dev";
      };
    };
  };
}

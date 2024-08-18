{pkgs, ...}:
let
  zinitSrc = builtins.fetchGit {
    url = "https://github.com/zdharma-continuum/zinit";
    rev = "30514edc4a3e67229ce11306061ee92db9558cec";
  };
in {
  programs.zsh = {
    enable = true;
    initExtra = ''
      source "${zinitSrc}/zinit.zsh"
    '' + builtins.readFile ./zshrc;

    shellAliases = {
      ln = "ln -v";
      ".." = "cd ..";
      "..." = "cd ../..";
      ls = "ls --color";
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";

      e = "$EDITOR";
      v = "$VISUAL";

      alpha = "echo 'a b c d e f g h i j k l m n o p q r s t u v w x y z'";

      path = "echo $PATH | tr -s ':' '\n'";
      root = "cd $(git rev-parse --show-cdup)";
      ":w" = "clear; echo \"You're not in vim but ok\"";
      ":q" = "exit";

      vi = "nvim";
      vim = "nvim";
    };
  };

  programs.starship.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.options = ["--cmd cd"];

  programs.fzf.enable = true;
  home.packages = with pkgs; [zinitSrc];

  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
    DOTFILES = "$HOME/.dotfiles";
    MEOW = "nya?";
    COLEMAK = "1";
  };
}

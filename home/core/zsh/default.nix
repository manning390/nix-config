{inputs, ...}: {
  programs.zsh = {
    enable = true;
    initExtra =
      ''
        source "${inputs.zinit}/zinit.zsh"
      ''
      + builtins.readFile ./zshrc;

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

      cat = "bat";
      path = "echo $PATH | tr -s ':' '\n'";
      root = "cd $(git rev-parse --show-cdup)";
      ":w" = "clear; echo \"You're not in vim but ok\"";
      ":q" = "exit";

      vi = "nvim";
      vim = "nvim";

      sound = "ncpamixer";
      led = "headsetcontrol -l 0";
    };
  };

  programs.starship.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.options = ["--cmd cd"];

  programs.fzf.enable = true;

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
    DOTFILES = "$HOME/.dotfiles";
    NIXCONFIG = "$HOME/nix-config";
    MEOW = "nya?";
    COLEMAK = "1";
  };
}

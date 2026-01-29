{inputs, ...}: {
  programs.zsh = {
    enable = true;
    initContent =
      ''
        source "${inputs.zinit}/zinit.zsh"
      ''
      + builtins.readFile ./zshrc;
  };

  programs.starship.enable = true;
  programs.nix-index.enableZshIntegration = true;
}

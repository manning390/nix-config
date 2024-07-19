{
  programs.zellij = {
    enable = true;
  };
  # auto start zellij in nushell
  programs.zsh.extraConfig = ''
    # auto start zellij
    if not "ZELLIJ" in $env {
      if "ZELLIJ_AUTO_ATTACH" in $env and $env.ZELLIJ_AUTO_ATTACH == "true" {
        ^zellij attach -c
      } else {
        ^zellij
      }

      # Auto exit the shell session when zellij exit
      $env.ZELLIJ_AUTO_EXIT = "false" # disable auto exit
      if "ZELLIJ_AUTO_EXIT" in $env and $env.ZELLIJ_AUTO_EXIT == "true" {
        exit
      }
    }
  '';

  home.shellAliases = {
    "zj" = "zellij";
  };

  xdg.configFile."zellij/config.kdl".source = ./config.kdl;
}

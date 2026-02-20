{
  lib,
  config,
  pkgs,
  vars,
  ...
}: let
  cfg = config.local.shells;
  shellPkg = shellName:
    if shellName == "bash"
    then pkgs.bashInteractive
    else if shellName == "zsh"
    then pkgs.zsh
    else if shellName == "fish"
    then pkgs.fish
    else null;
in {
  options.local.shells = {
    systemShell = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum ["bash" "zsh" "fish"]);
      default = null;
      description = ''
        Default login shell for all users.
        null = do not override users.defaultUserShell.
      '';
    };

    userShell = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum ["bash" "zsh" "fish"]);
      default = null;
      description = ''
        Login shell for the main user.
      '';
    };
  };

  config = let
    usesBash = cfg.systemShell == "bash" || cfg.userShell == "bash";
    usesZsh = cfg.systemShell == "zsh" || cfg.userShell == "zsh";
    usesFish = cfg.systemShell == "fish" || cfg.userShell == "fish";
  in {
    users.defaultUserShell = lib.mkIf (cfg.systemShell != null) (shellPkg cfg.systemShell);
    users.users.${vars.username}.shell = lib.mkIf (cfg.userShell != null) (shellPkg cfg.userShell);

    environment.systemPackages = with pkgs; [
      # shells
      bashInteractive
      zsh
      fish

      # Shell utils
      fzf # Fzf search
      fd # Better find
      bat # Better cat
      eza # Better ls
    ];

    programs.bash.enable = lib.mkIf usesBash true;
    programs.zsh.enable = lib.mkIf usesZsh true;
    programs.fish.enable = lib.mkIf usesFish true;

    environment.shellAliases = {
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
}

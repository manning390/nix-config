{
  flake.aspects.shells = {
    description = "Shared shell settings and setup.";
    nixos = {
      lib,
      config,
      pkgs,
      ...
    }: let
      cfg = config.local.shells;
      user = config.local.identity.username;
      typeDispatch = {
        "bash" = {pkg = pkgs.bashInteractive;};
        "zsh" = {pkg = pkgs.zsh;};
        "fish" = {pkg = pkgs.fish;};
      };
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
        uses = shell: cfg.systemShell == shell || cfg.userShell == shell;
      in {
        users.defaultUserShell = lib.mkIf (cfg.systemShell != null) (typeDispatch.${cfg.systemShell}.pkg);
        users.users.${user}.shell = lib.mkIf (cfg.userShell != null) (typeDispatch.${cfg.userShell}.pkg);

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

        programs.bash.enable = lib.mkIf (uses "bash") true;
        programs.zsh.enable = lib.mkIf (uses "zsh") true;
        programs.fish.enable = lib.mkIf (uses "fish") true;

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
          path = ''echo "$PATH" | tr -s ':' '\n' '';
          root = ''cd "$(git rev-parse --show-cdup 2>/dev/null || echo .)"'';
          ":w" = ''clear; echo "You're not in vim but ok"'';
          ":q" = ''exit'';

          vi = "nvim";
          vim = "nvim";

          sound = "ncpamixer";
          led = "headsetcontrol -l 0";
        };
      };
    };
  };
}

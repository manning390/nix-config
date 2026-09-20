{
  flake.aspects.tmux.homeManager = {pkgs, ...}: {
    programs.tmux = {
      enable = true;

      shortcut = "Space";
      baseIndex = 1;
      escapeTime = 0;

      plugins = with pkgs; [
        tmuxPlugins.sensible
        tmuxPlugins.yank
        tmuxPlugins.nord
      ];

      extraConfig = builtins.readFile ./tmux.conf;
    };
  };
}

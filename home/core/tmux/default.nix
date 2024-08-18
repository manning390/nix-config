{pkgs, ...}: {
  programs.tmux = {
    enable = true;

    shortcut = " ";
    baseIndex = 1;
    escapeTime = 0;

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank
      tmuxPlugins.nord
    ];

    extraConfig = builtins.readFile ./tmux.conf;
  };
}

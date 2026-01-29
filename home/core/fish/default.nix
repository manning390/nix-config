{config, pkgs, ...}: {
  programs.fish = {
    enable = true;
    plugins = [{
      name = "fzf-fish";
      src = pkgs.fishPlugins.fzf-fish.src;
    }];

    interactiveShellInit = ''
      # Colors
      set -g fish_color_autosuggiston brblack
      set -g fish_color_command brgreen
      set -g fish_color_error brred
      set -g fish_pager_color_prefix brcyan
      set -g fish_pager_color_completion normal
      set -g fish_pager_color_description brblack

      # sudo preprend (Alt-s)
      function __fish_prepend_sudo
        commandline -f beginning-of-line
        commandline -i 'sudo '
      end
      bind \es '__fish_prepend_sudo'

      set -g fish_greeting "Hi. Hello. Welcome. <3"
    '';
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.starship.enable = true; # Prompt
  programs.fzf.enableFishIntegration = false; # fzf-fish plugin conflict
}

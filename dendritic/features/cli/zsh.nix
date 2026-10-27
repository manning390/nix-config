{
  flake.aspects = {aspects, ...}: {
    zsh = {
      includes = with aspects; [starship nix-index];
      # Completion initialization is owned by the deferred user configuration.
      nixos.programs.zsh.enableGlobalCompInit = false;

      homeManager = {
        config,
        pkgs,
        ...
      }: let
        deferredPlugins =
          pkgs.writeText "zsh-deferred-plugins.zsh"
          # zsh
          ''
            fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
            autoload -Uz compinit
            # Skip insecure directories instead of prompting after startup.
            compinit -i

            source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh
            source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/command-not-found/command-not-found.plugin.zsh
            source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh

            # Completion must be initialized before fzf-tab wraps its widgets.
            source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
            source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
            # The first precmd has already run when this deferred batch loads.
            _zsh_autosuggest_start

            # Highlighting must be loaded after the other widget wrappers.
            source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
          '';
      in {
        programs.starship.enable = true;
        programs.zsh = {
          enable = true;
          defaultKeymap = "emacs";

          history = {
            size = 5000;
            append = true;
            share = true;
            ignoreSpace = true;
            ignoreDups = true;
            ignoreAllDups = true;
            saveNoDups = true;
            findNoDups = true;
          };

          # Keep completion packages/fpath setup, but defer compinit.
          completionInit = "";
          initContent =
            # zsh
            ''
              # Restore the directory before displaying the first prompt.
              ZSH_CACHE_DIR="${config.xdg.cacheHome}/zsh"
              mkdir -p -- "$ZSH_CACHE_DIR"
              source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/last-working-dir/last-working-dir.plugin.zsh

              source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
              # Defer plugins until after the prompt; keep errors visible.
              zsh-defer -2 source ${deferredPlugins}

              # Keybindings
              bindkey '^p' history-search-forward
              bindkey '^n' history-search-backward

              # Completion styling
              zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
              zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
              zstyle ':completion:*' menu no
              zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
              zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

              # Environment and local overrides
              export PATH=/usr/bin:~/.local/bin:$PATH

              [ -f ~/.profile ] && source ~/.profile

              echo "Hi. Hello. Welcome. <3"
            '';
        };
      };
    };
  };
}

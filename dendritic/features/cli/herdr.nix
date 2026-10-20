{
  flake.aspects.herdr = {
    description = "Herdr terminal workspace manager for AI coding agents";

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        github-copilot-cli
        unstable.herdr
      ];

      xdg.configFile."herdr/config.toml".text =
      # toml
      ''
        # Home Manager owns this file, so let onboarding know it cannot update it.
        onboarding = false

        [theme]
        name = "nord"

        [ui]
        status_indicators = "symbols"

        [keys]
        # Colemak-DH: keep Herdr's pane navigation on the same home-row keys as Neovim.
        focus_pane_left = "prefix+m"
        focus_pane_down = "prefix+n"
        focus_pane_up = "prefix+e"
        focus_pane_right = "prefix+i"

        navigate_pane_left = "m"
        navigate_pane_down = "n"
        navigate_pane_up = "e"
        navigate_pane_right = "i"
        # Workspace and pane navigation share a keymap, so use distinct keys.
        navigate_workspace_down = "down"
        navigate_workspace_up = "up"

        swap_pane_left = "prefix+shift+m"
        swap_pane_down = "prefix+shift+n"
        swap_pane_up = "prefix+shift+e"
        swap_pane_right = "prefix+shift+i"

        # Match Neovim's Colemak-DH n/N -> h/H next/previous convention.
        next_tab = "prefix+h"
        previous_tab = "prefix+shift+h"
      '';
    };
  };
}

{lib, ...}: {
  imports = [ ] ++ builtins.map lib.custom.relativeToRoot [
    "home/linux/desktop.nix"
    "home/core/default.nix"
  ];

  custom.wm.caelestia.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.options = ["--cmd cd"];
  programs.fzf.enable = true;

  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
    DOTFILES = "$HOME/.dotfiles";
    NIXCONFIG = "$HOME/Code/nix/nix-config";
    COLEMAK = "1";
  };

  home.stateVersion = "23.11";
}

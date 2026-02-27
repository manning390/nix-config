{lib, inputs, ...}: {
  # inputs.nix-private.homeManagerModules
  imports = [  ] ++ builtins.map lib.custom.relativeToRoot [
    "home/linux/desktop.nix"
    "home/core/default.nix"
  ];

  local.wm.caelestia.enable = true;
  # local.ssh.hosts = [ "pch@glaciem" "pch@sentry" ];

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

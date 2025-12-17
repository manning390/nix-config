{...}: {
  programs.fish = {
    enable = true;
    plugins = [ ];
  };
  programs.fzf.enableFishIntegration = true;
  programs.nix-index.enableFishIntegration = true;
}

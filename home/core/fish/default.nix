{...}: {
  programs.fish = {
    enable = true;
    plugins = [ ];
  };
  programs.fzf.enableFishIntegration = true;
}

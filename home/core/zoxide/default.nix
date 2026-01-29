{...}:{
          # Go to anywhere with z or cd override
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration  = true;
    enableFishIntegration = true;

    options = [
      "--cmd cd"
    ];
  };
}

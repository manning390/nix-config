{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    fzf
  ];
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
  };
}

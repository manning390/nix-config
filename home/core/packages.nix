{pkgs, ...}: {
  # home.packages = with pkgs; [];

  programs = {
    man.enable = true;
    tmux = {
      enable = true;
      # configs wip
    };
    bat = {
      enable = true;
      # configs wip
    };
    fd.enable = true; # says doesn't exist?
    btop.enable = true;
    jq.enable = true;
    aria2.enable = true;
  };
}

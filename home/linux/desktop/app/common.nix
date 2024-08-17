{lib, pkgs, ...}: {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    p7zip

    # utils
    ripgrep
    fzf
    _1password
    
    # networking
    nmap
  ];

  programs = {
    tmux = {
      enable = true;
      # configs wip
    };
    bat = {
      enable = true;
      # configs wip
    };
    btop.enable = true;
    jq.enable = true;
    aria2.enable = true;
  };
}

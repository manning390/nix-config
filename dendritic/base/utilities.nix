{
  flake.aspects.utilities = {
    nixos = {pkgs, ...}:{
      environment.systemPackages = with pkgs; [
        eza
        fzf
        stow
        zip
        unzip
        p7zip
        htop
        pciutils
        just
      ];
    };

    homeManager = {
      programs = {
        man.enable = true;
        bat = {
          enable = true;
          # configs wip
        };
        fd.enable = true; # says doesn't exist?
        btop.enable = true;
        jq.enable = true;
      };
    };
  };
}

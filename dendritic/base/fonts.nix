{
  flake.aspects.fonts.nixos = {pkgs,...}: {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.noto
      ];
    };
  };
}

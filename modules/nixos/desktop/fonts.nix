{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # Nerdfonts is too big, only grab what we want
      (nerdfonts.override { fonts = ["FiraCode" "DroidSansMono" "Noto"]; })
    ];
  };
}

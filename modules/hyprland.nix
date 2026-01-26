{
  pkgs,
  inputs,
  vars,
  config,
  lib,
  ...
}: let
  userShell = config.users.users.${vars.username}.shell or null;
  uwsmStartSnippet = ''
    if uwsm check may-start
      exec uwsm start hyprland-uwsm.desktop
    end
  '';
in {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  environment.systemPackages = with pkgs;
    [
      rofi # Application launcher
      fuzzel # Another application launcher
      app2unit # similar to UWSM, daemon launcher, faster
      hyprlock # lock screen
      hyprcursor # Better cursors
      hypridle # System idle
      hyprpicker # Color picker
      hyprpolkitagent # Escalate priviledges
      nwg-look # GTK3 settings editor
      playerctl
      brightnessctl
      mako
    ]
    ++ [
      inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast # or any other package
    ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-hyprland];

  programs.bash.interactiveShellInit = lib.mkIf (userShell == pkgs.bashInteractive) uwsmStartSnippet;
  programs.zsh.interactiveShellInit = lib.mkIf (userShell == pkgs.zsh) uwsmStartSnippet;
  programs.fish.interactiveShellInit = lib.mkIf (userShell == pkgs.fish) uwsmStartSnippet;
}

{
  flake.modules.foundation.security = {
    nixos = {pkgs, ...}: {
      security.rtkit.enable = true;
      security.polkit.enable = true;

      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    };
  };
}

{
  flake.aspects.security = {
    nixos = {pkgs, ...}: {
      security.polkit.enable = true;

      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    };
  };
}

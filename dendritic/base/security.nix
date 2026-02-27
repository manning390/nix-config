{
  flake.aspects.security = {
    nixos = {pkgs, lib, ...}: {
      security.polkit.enable = true;

      programs.gnupg.agent = lib.mkForce {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    };
  };
}

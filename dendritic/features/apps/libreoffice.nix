{
  flake.aspects.libreoffice.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      unstable.libreoffice
      hunspell
      hunspellDicts.en_US-large
      hunspellDicts.en_GB-large
    ];
  };
}

{lib,...}: {
  flake.aspects.localization.nixos = {
    time.timeZone = lib.mkDefault "America/Los_Angeles";
    i18n.defaultLocale = "en_US.UTF-8";
  };
}

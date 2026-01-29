{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    firefox
    # inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin
    brave
  ];
}

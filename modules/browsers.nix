{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    firefox-bin
    # inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin
    brave
  ];
}

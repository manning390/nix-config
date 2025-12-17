{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # firefox
    inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
    brave
  ];
}

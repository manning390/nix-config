{
  flake.aspects.browsers.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      firefox
      brave
    ];
  };
}

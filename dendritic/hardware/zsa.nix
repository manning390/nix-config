{
  flake.aspects.hardware._.zsa = {
    description = "Additional configurations and software to support zsa keyboards";
    nixos = {pkgs, ...}: {
      hardware.keyboard.zsa.enable = true;
      environment.systemPackages = with pkgs; [
        wally-cli
        keymapp
      ];
    };
  };
}

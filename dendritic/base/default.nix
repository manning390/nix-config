{
  flake.aspects = {aspects, ...}: {
    base = {
      description = "Base Aspect includes things installed on every system.";

      includes = with aspects; [
        nix
        git
        sops
        security
        networking
        localization
        utilities
        fonts
        keyboards
      ];

      nixos = {
        lib,
        pkgs,
        ...
      }: {
        environment.systemPackages = with pkgs; [vim fastfetch]; # Always keep one text editor
        local = {
          git.enable = lib.mkDefault true;
          sops.enable = lib.mkDefault true;
          hardware.networking.enable = lib.mkDefault true;
        };
      };
    };
  };
}

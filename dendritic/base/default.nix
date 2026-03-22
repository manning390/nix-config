{inputs,...}: {
  flake.aspects = {aspects, ...}: {
    base = {
      description = "Base Aspect is a collection of aspects to installed on every system.";

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
        imports = [ inputs.nix-private.nixosModules.ssh ];
        local = {
          git.enable = lib.mkDefault true;
          sops.enable = lib.mkDefault true;
          hardware.networking.enable = lib.mkDefault true;
        };
      };

      homeManager = {
        imports = [ inputs.nix-private.homeManagerModules.ssh ];
        programs.ssh.enableDefaultConfig = false; # Spewing errors about an option being depreciated, then it will spew errors about this one beign depreciated once it's depreciated.
      };
    };
  };
}

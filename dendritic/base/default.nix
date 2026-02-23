{
  flake.aspects = {aspects,...}: {
    base = {
      description = "Base Aspect includes things installed on every system.";

      includes = with aspects; [
        nix
        git
        sops
        security
        localization
      ];

      nixos = {lib,pkgs,...}: {
        environment.systemPackages = [ pkgs.vim ]; # Never remove a text editor
        local = {
          git.enable = lib.mkDefault true;
          sops.enable = lib.mkDefault true;
        };
      };
    };
  };
}

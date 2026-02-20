{
  flake.aspects = {aspects,...}: {
    base = {
      includes = with aspects; [
        identity
        nix
        git
        sops
        security
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

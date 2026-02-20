{
  flake.aspects.base = {aspects, ...}: {
    includes = with aspects; [
      nix
      git
      sops
      security
    ];

    nixos = {lib,pkgs,...}: {
      environment.systemPackages = [ pkgs.vim ]; # Never remove a text editor
      local = {
        git = lib.mkDefault true;
        sops = lib.mkDefault true;
      };
    };
  };
}

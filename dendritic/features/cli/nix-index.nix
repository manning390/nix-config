{inputs, ...}: {
  flake.aspects.nix-index = {
    nixos = {
      imports = [inputs.nix-index-database.nixosModules.default];
      programs.nix-index-database.comma.enable = true;

      # programs.nix-index = {
      #   enable = true;
      #   enableBashIntegration = true;
      #   enableZshIntegration = true;
      #   enableFishIntegration = true;
      # };
    };
  };
}

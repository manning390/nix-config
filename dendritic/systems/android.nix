{self, ...}: {
  flake-file.inputs.nix-on-droid = {
    url = "github:nix-community/nix-on-droid";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };

  # Upstream's switch command looks up this conventional output name.
  flake.nixOnDroidConfigurations = self.androidConfigurations;

  flake.aspects.android = {
    description = "Minimal Android terminal environment, without NixOS services or privileged users.";

    android = {pkgs, ...}: {
      environment.packages = with pkgs; [
        git
        neovim
        openssh
        ripgrep
        tmux
      ];

      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };
}

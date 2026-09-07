# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Nix Configurations of Manning390";

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./dendritic);

  inputs = {
    browser-bookmarks = {
      url = "github:dhruvmanila/browser-bookmarks.nvim";
      flake = false;
    };
    caelestia-shell.url = "github:caelestia-dots/shell";
    cmp-async-path = {
      url = "git+https://codeberg.org/FelipeLema/cmp-async-path";
      flake = false;
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    disko.url = "github:nix-community/disko";
    flake-aspects.url = "github:denful/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    github-coauthors = {
      url = "github:cwebster2/github-coauthors.nvim";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    hyprland-contrib.url = "github:hyprwm/contrib";
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-auto-follow = {
      url = "github:fzakaria/nix-auto-follow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-private.url = "git+ssh://git@github.com/manning390/nix-private";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    none-ls-extras = {
      url = "github:nvimtools/none-ls-extras.nvim";
      flake = false;
    };
    none-ls-php = {
      url = "github:gbprod/none-ls-php.nvim";
      flake = false;
    };
    sops-nix.url = "github:Mic92/sops-nix";
    tailiscope = {
      url = "github:danielvolchek/tailiscope.nvim";
      flake = false;
    };
    tailwind-fold = {
      url = "github:razak17/tailwind-fold.nvim";
      flake = false;
    };
    telescope-emoji = {
      url = "github:xiyaowong/telescope-emoji.nvim";
      flake = false;
    };
    telescope-heading = {
      url = "github:crispgm/telescope-heading.nvim";
      flake = false;
    };
    wrd-nvim = {
      url = "github:manning390/wrd.nvim/dev";
      flake = false;
    };
    zinit = {
      url = "github:zdharma-continuum/zinit";
      flake = false;
    };
  };
}

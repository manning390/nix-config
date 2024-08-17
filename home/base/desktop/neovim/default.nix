{pkgs, lib, ...}: {
  nixpkgs.config = {
    programs.npm.npmrc = ''
      prefix = ''${HOME}/.npm-global
    '';
  };

  home.packages = with pkgs; [
    llvmPackages.clang-unwrapped # c/c++ tools with clang tools
    # Required by nvim-treesitter
    # Must be installed after clang
    gcc
  ];

  programs.nano.enable = lib.mkForce false;

  home.shellAliases = {
    "bi" = "echo \"🏳️‍🌈\";sleep 1;nvim";
    ":w" = "clear; echo \"You're not in vim but ok\"";
    ":q" = "exit";
    # Not in this house
    "nano" = "nvim";
    "emacs" = "echo \"Bless you\";sleep 1;nvim";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [

    ];
  };
}

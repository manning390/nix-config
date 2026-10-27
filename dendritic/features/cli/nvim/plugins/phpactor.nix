# PHP refactoring and code actions using the Nix-provided Phpactor executable.
# Load for PHP/Blade buffers or :PhpActor; shared LSP setup handles the server.
{
  flake-file.inputs.phpactor-nvim = {
    url = "github:gbprod/phpactor.nvim/v1.0.1";
    flake = false;
  };

  local.nvim.plugins.phpactor = {
    input = "phpactor-nvim";
    dependencies = pkgs: with pkgs.vimPlugins; [plenary-nvim nvim-lspconfig];
    extraPackages = pkgs: [pkgs.phpactor];
    lua =
      # lua
      ''
        {
          "phpactor-nvim",
          ft = { "php", "blade" },
          cmd = "PhpActor",
          main = "phpactor",
          opts = {
            install = {
              bin = "phpactor",
              php_bin = "", -- Run Nix's executable wrapper directly.
              check_on_startup = "none",
            },
            lspconfig = { enabled = false },
          },
        }
      '';
  };
}

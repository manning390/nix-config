let
  sources =
    {
      cmp-async-path = "cmp-async-path";
      cmp-buffer = "cmp-buffer";
      cmp-calc = "cmp-calc";
      cmp-luasnip = "cmp_luasnip";
      cmp-nvim-lua = "cmp-nvim-lua";
      cmp-path = "cmp-path";
      cmp-signature-help = "cmp-nvim-lsp-signature-help";
      cmp-spell = "cmp-spell";
    }
    |> builtins.mapAttrs (_: package: {
      inherit package;
      lua =
        # lua
        ''{ "${package}", on_plugin = "nvim-cmp", load = require("config.loader").with_after } '';
    });
in {
  local.nvim.plugins =
    sources
    // {
      cmp = {
        package = "nvim-cmp";
        lua =
          # lua
          ''
            {
              "nvim-cmp",
              event = "InsertEnter",
              on_require = "cmp",
              before = function()
                require("lze").trigger_load("nvim-autopairs")
              end,
              after = function()
                require("config.cmp")
              end,
            }
          '';
      };

      cmp-nvim-lsp = {
        package = "cmp-nvim-lsp";
        optional = false; # LSP capabilities must be available before completion loads.
      };
    };
}

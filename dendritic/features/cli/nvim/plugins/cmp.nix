# Completion menu and sources for buffers, paths, snippets, spelling, and Lua.
# Load on InsertEnter; LSP capability support stays available at startup.
let
  sources =
    {
      cmp-async-path = "cmp-async-path"; # Asynchronous filesystem path completion.
      cmp-buffer = "cmp-buffer"; # Complete words from buffer contents.
      cmp-calc = "cmp-calc"; # Complete arithmetic expression results.
      cmp-luasnip = "cmp_luasnip"; # Complete LuaSnip snippets.
      cmp-nvim-lua = "cmp-nvim-lua"; # Complete Neovim's Lua API.
      cmp-path = "cmp-path"; # Filesystem path completion.
      cmp-signature-help = "cmp-nvim-lsp-signature-help"; # Display LSP function signatures.
      cmp-spell = "cmp-spell"; # Complete spelling suggestions.
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

      # Advertise completion capabilities to language servers before they attach.
      cmp-nvim-lsp = {
        package = "cmp-nvim-lsp";
        optional = false; # LSP capabilities must be available before completion loads.
      };
    };
}

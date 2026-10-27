{
  local.nvim.plugins.codecompanion = {
    package = "codecompanion-nvim";
    lua =
      # lua
      ''
        {
          "codecompanion.nvim",
          cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
          on_require = "codecompanion",
          main = "codecompanion",
          opts = { interactions = { chat = { adapter = "copilot_acp" } } },
        }
      '';
  };
}

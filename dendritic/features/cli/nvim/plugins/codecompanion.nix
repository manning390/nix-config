# AI-assisted editing, chat, and actions; load through commands or Lua API use.
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

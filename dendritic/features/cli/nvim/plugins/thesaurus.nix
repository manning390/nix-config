{
  local.nvim.plugins.thesaurus = {
    package = "thesaurus_query-vim";
    lua =
      # lua
      ''
        {
          "thesaurus_query.vim",
          cmd = { "ThesaurusQueryReplace", "ThesaurusQueryReplaceCurrentWord" },
          beforeAll = function()
            vim.g.tq_openoffice_en_file = "~/Documents/MyThes-1.0/th_en_US_new"
            vim.g.tq_enabled_backends = { "openoffice_en", "datamuse_com" }
          end,
        }
      '';
  };
}

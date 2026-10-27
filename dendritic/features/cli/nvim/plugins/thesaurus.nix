# Find synonyms and replace words using local or online thesaurus backends.
# Load through thesaurus commands.
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

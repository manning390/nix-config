# Run test suites, files, and nearby tests from Neovim.
# Currently disabled; when enabled, load through test commands.
{
  local.nvim.plugins.nvim-test = {
    enable = false;
    package = "nvim-test";
    lua =
      # lua
      ''
        {
          "nvim-test",
          cmd = { "TestSuite", "TestFile", "TestEdit", "TestNearest", "TestLast", "TestVisit", "TestInfo" },
          main = "nvim-test",
          opts = {
            silent = true,
            term = "terminal",
            termOpts = {
              direction = "horizontal",
              stopinsert = true,
              keep_one = true,
            },
            runners = { cs = "nvim-test.runners.dotnet" },
          },
          after = function()
            require("nvim-test.runners.jest"):setup({
              args = { "--config=./src/test/js/jest.config.js", "--coverage=false", "--verbose=false" },
            })
          end,
        }
      '';
  };
}

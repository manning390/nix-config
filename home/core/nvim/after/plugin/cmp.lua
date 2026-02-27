local cmp = require('cmp')
local has_luasnip, luasnip = pcall(require, 'luasnip')
local n = vim.g.keymaps.n;

require('config.snippets')
require('config.cmp.githandles').setup()

cmp.register_source("easy-dotnet", require "easy-dotnet".package_completion_source)
cmp.setup({
  snippet = {
    expand = function(args)
      if has_luasnip then
        luasnip.lsp_expand(args.body)
      end
    end
  },
  mapping = cmp.mapping.preset.insert {
    -- ['<C-n>'] = cmp.mapping.select_next_item {behavior = cmp.SelectBehavior.Insert },
    -- ['<C-e>'] = cmp.mapping.select_prev_item {behavior = cmp.SelectBehavior.Insert },
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-' .. n .. '>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-S-' .. n .. '>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<esc>'] = cmp.mapping.close(),
  },
  sources = {
    -- Configuration Opions
    --     keyword_length
    --     priority (also ordering sources in list)
    --     max_item_count
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    -- { name = 'nvim_lsp_signature_help' },
    { name = 'easy-dotnet' },
    { name = 'async_path' },
    { name = 'calc' },
    { name = 'luasnip' },
    {
      name = 'emmet_vim',
      option = {
        filetypes = {
          'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte', 'vue'
        }
      }
    },
    { name = 'buffer', keyword_length = 5 },
    { name = 'spell' },
    { name = 'emoji' },
    -- { name = 'cmdline'},
  },
  experimental = {
    native_menu = false,
    ghost_text = false,
  },
  window = {
    documentation = cmp.config.window.bordered(),
  }
})
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources(
    { name = 'githandles' }
  ),
})
cmp.event:on(
  'confirm_done',
  require('nvim-autopairs.completion.cmp').on_confirm_done()
)

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

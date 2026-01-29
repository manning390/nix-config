-- vim.lsp.set_log_level('debug')
-- local efm_languages = { 
--     lua = { require('efml-configs.formatters.stylua') }
-- }
vim.lsp.enable('clangd', {
    init_options = {
        compilationDatabaseDirectory = "build"
    }
})
vim.lsp.enable('emmet_language_server', {
    filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte', 'vue' },
})
vim.lsp.enable('cmake')
vim.lsp.enable('tailwindcss')
vim.lsp.enable('nixd')
vim.lsp.enable('vimls')
vim.lsp.enable('cssls', {
    on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end,
})
vim.lsp.enable('eslint', {
    filetypes = {'javascriptreact', 'typescriptreact', 'javascript', 'svelte'},
    on_attach = function(_, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
            vim.lsp.buf.format()
            vim.cmd('EslintFixAll')
        end, { desc = 'Format current buffer with LSP' })
    end,
})
vim.lsp.enable('lua_ls', {
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using
                        -- (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT'
                    },
                    -- Make the server aware of Neovim runtime files
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME

                            -- "${3rd}/luv/library"
                            -- "${3rd}/busted/library",
                        }
                        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                        -- library = vim.api.nvim_get_runtime_file("", true)
                    },
                    telemetry = { enable = false },
                    diagnostics = { globals = { 'vim', 'require' } },
                    completion = {
                        callSnippet = "Replace"
                    }
                }
            })
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        return true
    end,
})
vim.lsp.enable('jsonls')

-- vim.lsp.config.intelephense.init_options = {}
local servers = {
    -- tsserver = {
    --     on_attach = function(client)
    --         client.server_capabilities.documentFormattingProvider = false
    --         client.server_capabilities.documentRangeFormattingProvider = false
    --     end,
    -- },
    -- phpactor = {},
    -- intelephense = {
    --     init_options = {
    --         -- licenceKey = (function()
    --         --     local f = assert(io.open(os.getenv("HOME") .. "/intelephense/license.txt", "rb"))
    --         --     local content = f:read("*line")
    --         --     f:close()
    --         --     return content
    --         -- end)()
    --     }
    -- },
    -- cssls = {
    --     on_attach = function(client)
    --         client.server_capabilities.documentFormattingProvider = false
    --         client.server_capabilities.documentRangeFormattingProvider = false
    --     end,
    -- },
    -- eslint = {
    --     filetypes = {'javascriptreact', 'typescriptreact', 'javascript', 'svelte'},
    --     on_attach = function(_, bufnr)
    --         vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    --             vim.lsp.buf.format()
    --             vim.cmd('EslintFixAll')
    --         end, { desc = 'Format current buffer with LSP' })
    --     end,
    -- },
    -- lua_ls = {
    --     on_init = function(client)
    --         local path = client.workspace_folders[1].name
    --         if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
    --             client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
    --                 Lua = {
    --                     runtime = {
    --                         -- Tell the language server which version of Lua you're using
    --                         -- (most likely LuaJIT in the case of Neovim)
    --                         version = 'LuaJIT'
    --                     },
    --                     -- Make the server aware of Neovim runtime files
    --                     workspace = {
    --                         checkThirdParty = false,
    --                         library = {
    --                             vim.env.VIMRUNTIME
    --
    --                             -- "${3rd}/luv/library"
    --                             -- "${3rd}/busted/library",
    --                         }
    --                         -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
    --                         -- library = vim.api.nvim_get_runtime_file("", true)
    --                     },
    --                     telemetry = { enable = false },
    --                     diagnostics = { globals = { 'vim', 'require' } },
    --                     completion = {
    --                         callSnippet = "Replace"
    --                     }
    --                 }
    --             })
    --             client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    --         end
    --         return true
    --     end,
    -- },
    -- efm = {
    --    filetypes = vim.tbl_keys(efm_languages),
    --    settings = {
    --        rootMarkers = { ".git/" },
    --        languages = vim.tbl_extend('force',
    --            require 'efmls-configs.defaults'.languages(), efm_languages
    --        )
    --   },
    --   init_options = {
    --     documentFormatting = true,
    --     documentRangeFormatting = true,
    --   },
    -- },
    -- ltex = {
    --     filetypes = { 'markdown' },
    --     filter_notifications = {
    --         'checking document'
    --     },
    --     -- on_init = function(client)
    --     --     client.server_capabilities
    --     -- end
    -- },
    -- nixd = {},
    -- svelte = {},
 -- godot = (os.getenv("GODOT") and {} or nil)
}

vim.diagnostic.config({
    virtual_text = true,
    float = {
        source = true,
    }
})

require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to serveres
capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
--
-- This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format({ async = false })
    end, { desc = 'Format current buffer with LSP' })
end

vim.lsp.config('*', {
    capabilities = capabilities,
    on_attach = on_attach,
})

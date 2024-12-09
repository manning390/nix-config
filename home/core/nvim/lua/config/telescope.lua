local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        file_sorter = require("telescope.sorters").get_fzy_sorter,
        prompt_prefix = " >",
        color_devicons = true,

        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

        file_ignore_patterns = {
            "node_modules",
            "vendor"
        },

        mappings = {
            i = {
                ["<C-u>"] = false,
                ["<C-d>"] = false,
                ["<C-q>"] = actions.send_to_qflist,
                ["<C-g>"] = actions.send_to_qflist,
            },
        },

    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        },
    },
})

pcall(require("telescope").load_extension, "fzy")
pcall(require("telescope").load_extension, "git_worktree")
pcall(require("telescope").load_extension, "emoji")

local M = {}
M.search_dotfiles = function()
    require("telescope.builtin").find_files({
        find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
        prompt_title = "< DOTFILES >",
        cwd = vim.env.DOTFILES,
    })
end
M.search_nixconfig = function()
    require("telescope.builtin").find_files({
        find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
        prompt_title = "< Nix Config >",
        cwd = vim.env.NIXCONFIG,
    })
end
M.project_files = function()
    local opts = { show_untracked = true }
   local ok = pcall(require 'telescope.builtin'.git_files, opts)
    if not ok then require 'telescope.builtin'.find_files(opts) end
end
M.related_files = function()
    local removeAfterLastSlash = function(s)
        return string.sub(s, 1, string.find(s, '/[^/]*$') - 1)
    end

    local path = removeAfterLastSlash(vim.fn.expand('%'))
    local opath = ''

    -- Set opposite path to the opposite side of the project
    if string.find(path, 'test') then
        opath = string.gsub(path, 'test', 'main')
    else
        opath = string.gsub(path, 'main', 'test')
    end

    -- Make the opposite path the longer of the two paths
    if #path > #opath then
        local tmp = path
        path = opath
        opath = tmp
    end

    -- Get to the closest existing directory
    while opath ~= '' and vim.fn.isdirectory(opath) ~= 1 do
        opath = removeAfterLastSlash(string.sub(opath, 1, -2))
    end

    -- Open telescope
    require 'telescope.builtin'.find_files({
        find_command = { 'rg', path, opath, '--files'},
        prompt_title = "< RELATED >",
    })
end
M.fuzzy_buffer = function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes')
        .get_dropdown {
            winblend = 10,
            previewer = false,
        })
end

return M

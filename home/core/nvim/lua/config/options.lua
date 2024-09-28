--filetype plugin indent on
--syntax on
local cache_dir = os.getenv('HOME') .. '/.cache/nvim/'

vim.env.BASH_ENV = '~/.aliases'

vim.o.termguicolors = true
vim.cmd [[colorscheme nordfox]]
vim.o.mouse = 'nv'
vim.o.errorbells = false
vim.o.encoding = 'utf-8'
vim.o.fileformats = 'unix,mac,dos'
vim.o.magic = true
vim.o.tabstop = 4 --A tab is four spaces
-- vim.o.softtabstop = 4
-- vim.o.shiftwidth = 4 -- number of spaces to use for autoindenting
vim.o.expandtab = true --always convert tabs to spaces
vim.o.smartindent = true
vim.o.autoindent = true --always set autoindenting on
vim.o.copyindent = true --copy the previos indentation on autoindenting
vim.o.preserveindent = true --preserves original tabs or spaces in use
vim.o.shiftround = true --use multiple of shiftwidth when indenting with '<' and '>'
vim.o.clipboard = 'unnamedplus'

vim.o.undofile = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.directory = cache_dir .. 'swag/'
vim.o.undodir = cache_dir .. 'undo/'
vim.o.backupdir = cache_dir .. 'backup/'
vim.o.viewdir = cache_dir .. 'view/'
-- vim.o.spellfile = cache_dir .. 'spell/en.uft-8.add'
-- let &directory=g:configPath .'/swap//' --vim.o.where we're saving swaps
-- let &undodir=g:configPath .'/undo//' --and undos


vim.o.sidescroll = 1 --sidescroll when needed
vim.o.wrap = false --don't wrap lines
vim.o.linebreak = true
--vim.o.colorcolumn = "80"
vim.signcolumn = "yes"
vim.o.completeopt = 'menuone,noselect'

vim.o.hidden = true --hides buffers rather than closing them when not active
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false
--vim.o.listchars=eol:¬,tab:>-,trail:~,extends:>,precedes:<,space:·
vim.o.listchars = "eol:¶,tab:>·,trail:~,extends:>,precedes:<,space:·"

--vim.o.formatoptions-=ro

vim.wo.number = true
vim.wo.relativenumber = true --Show line numbers Relative line numbers
vim.o.showmatch = true--show matching parenthesis
vim.o.cursorline = true--show what line the cursor is on
vim.o.title = true--show title in window
vim.o.showmode = false --Hides original status line
vim.o.ruler = false
vim.o.breakat = [[\ \	;:,!?]];
-- vim.o.rulerformat = '%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)' -- A ruler on steroids
vim.o.showcmd = true
vim.o.tabpagemax = 15

vim.g.indent_guides_start_level = 2
vim.g.indent_guides_guide_size = 1

-- Search
vim.o.hlsearch   = false --highlight search terms
vim.o.incsearch  = true --show search matches as you type
vim.o.ignorecase = true
vim.o.smartcase  = true --ignore case if search pattern is all lowercase
vim.o.infercase = true
vim.o.wrapscan = true
vim.o.startofline = false
vim.o.whichwrap = 'h,l,<,>,[,],~';
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.switchbuf = 'useopen'
vim.o.backspace= 'indent,eol,start' --allow backspacing over everything in insert mode

vim.o.update = 250
--[[
-- Auto commands (run functions/snippets)

augroup general
	autocmd FileType vim setlocal fo-=cro --Stop comment continuation on new lines and autowrapping
		" Strip trailing whitespace after save on every file
	autocmd BufWritePre * call StripTrailingWhitespace() --after save on every file trim trailing whitespace
augroup END

-- Hybrid number lines
-- When in normal mode, relative numbers otherwise normal
-- https://jeffkreeftmeijer.com/vim-number/
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * vim.o.relativenumber
	autocmd BufLeave,FocusLost,InsertEnter   * vim.o.norelativenumber
augroup END

" Load project specific settings, don't output error
" Expects vim to always open at root of project
" Run last incase we want to overwrite anything
try
	source .vimlocal.vim
catch
	" No worries, ignore it
endtry
]]

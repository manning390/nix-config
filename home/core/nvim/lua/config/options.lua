--filetype plugin indent on
--syntax on
local cache_dir = os.getenv('HOME') .. '/.cache/nvim/'

-- vim.env.BASH_ENV = '~/.aliases'
vim.g.python3_host_prog = '/usr/bin/python3'

vim.o.wildignore = table.concat({"__pycache__", "*.o", "*~", "*.pyc", "*pycache*" }, ',')

vim.o.showmode = false
vim.o.showcmd = true
vim.o.cmdheight = 1

vim.o.termguicolors = true
vim.o.mouse = 'nv'
vim.o.errorbells = false
-- vim.o.errorformat = '%A%f:%l:%c:%m,%-G\\\\s%#,%-G%*\\\\d\\ problem%.%#'
vim.o.encoding = 'utf-8'
vim.o.fileformats = 'unix,mac,dos'
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.o.magic = true

vim.o.tabstop = 4      --A tab is four spaces
vim.o.softtabstop = 4
vim.o.shiftwidth = 4   -- number of spaces to use for autoindenting
vim.o.expandtab = true --always convert tabs to spaces

vim.o.smartindent = true
vim.o.autoindent = true     --always set autoindenting on
-- vim.o.copyindent = true     --copy the previos indentation on autoindenting
vim.o.preserveindent = true --preserves original tabs or spaces in use
vim.o.shiftround = true     --use multiple of shiftwidth when indenting with '<' and '>'
vim.o.clipboard = 'unnamedplus'

vim.o.undofile = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.directory = cache_dir .. 'swag/'
vim.o.undodir = cache_dir .. 'undo/'
vim.o.backupdir = cache_dir .. 'backup/'
vim.o.viewdir = cache_dir .. 'view/'
vim.o.spellfile = cache_dir .. 'spell/en.uft-8.add'
vim.o.spelllang = 'en_us'
-- let &directory=g:configPath .'/swap//' --vim.o.where we're saving swaps
-- let &undodir=g:configPath .'/undo//' --and undos

vim.o.sidescroll                = 1 --sidescroll when needed
vim.o.wrap                      = true
vim.o.breakindent               = true
vim.o.breakindentopt            = 'shift:2,min:40,sbr'
vim.o.showbreak                 = '>>'
vim.o.linebreak                 = true
--vim.o.colorcolumn = "80"
vim.signcolumn                  = "yes"
vim.o.completeopt               = 'menuone,noselect'
vim.o.foldmethod                = "marker"
vim.o.foldlevel                 = 0
vim.o.modelines                 = 1
-- vim.o.foldmethod = "expr"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevelstart            = 99
--vim.o.listchars=eol:¬,tab:>-,trail:~,extends:>,precedes:<,space:·
vim.o.listchars                 = "eol:¶,tab:>·,trail:~,extends:>,precedes:<,space:·"
-- vim.o.formatoptions             = vim.o.formatoptions
-- 	- "a" -- Auto formatting is BAD.
-- 	- "t" -- Don't auto format my code. I got linters for that.
-- 	+ "c" -- In general, I like it when comments respect textwidth
-- 	+ "q" -- Allow formatting comments w/ gq
-- 	- "o" -- O and o, don't continue comments
-- 	+ "r" -- But do continue when pressing enter.
-- 	+ "n" -- Indent past the formatlistpat, not underneath it.
-- 	+ "j" -- Auto-remove comments if possible.
-- 	- "2" -- I'm not in gradeschool anymore
vim.o.formatoptions = 'cqrn'
vim.o.conceallevel = 1;

vim.wo.number                   = true
vim.wo.relativenumber           = true --Show line numbers Relative line numbers
vim.o.showmatch                 = true --show matching parenthesis
vim.o.cursorline                = true --show what line the cursor is on
vim.o.title                     = true --show title in window
vim.o.showmode                  = false --Hides original status line
vim.o.ruler                     = false
vim.o.breakat                   = [[\ \	;:,!?]];
-- vim.o.rulerformat = '%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)' -- A ruler on steroids
vim.o.showcmd                   = true
vim.o.tabpagemax                = 15

vim.g.indent_guides_start_level = 2
vim.g.indent_guides_guide_size  = 1

-- Search
vim.o.hlsearch                  = true --highlight search terms
vim.o.incsearch                 = true --show search matches as you type
vim.o.ignorecase                = true
vim.o.smartcase                 = true --ignore case if search pattern is all lowercase
vim.o.infercase                 = true
vim.o.wrapscan                  = true
vim.o.startofline               = false
vim.o.whichwrap                 = 'h,l,<,>,[,],~';
vim.o.splitbelow                = true
vim.o.splitright                = true
vim.o.switchbuf                 = 'useopen'
vim.o.backspace                 = 'indent,eol,start' --allow backspacing over everything in insert mode

-- vim.o.update                    = 250
--
vim.filetype.add({
  pattern = {
    ['.*%.blade%.php'] = 'blade',
  },
})

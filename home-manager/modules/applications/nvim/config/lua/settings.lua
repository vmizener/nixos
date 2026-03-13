local M = {}
M.ALL = {
    'set_options',
    'set_autocommands',
}

function M.set_options()
    local set = vim.opt

    set.autoindent = true       -- Automatic indentation
    set.smartindent = true      -- Detect language-based indentation levels
    set.cmdheight = 0           -- Hide the command line by default
    set.background = 'dark'     -- Use dark colorscheme for background
    set.breakindent = true      -- Indent line-breaks to align with code
    set.confirm = true          -- Confirm quit if there're unsaved changes
    set.expandtab = true        -- Fill tabs with spaces
    set.hidden = true           -- Don't require writing buffers before hiding them
    set.hlsearch = true         -- Highlight search results
    set.incsearch = true        -- Do incremental search
    set.ignorecase = true       -- Do case-insensitive search ...
    set.smartcase = true        -- ... unless capital letters are used
    set.history = 500           -- MOAR history
    set.modeline = true         -- MOAR modeline
    set.mouse = 'a'             -- MOAR mouse
    set.undolevels = 500        -- MOAR undo
    set.backup = false          -- No .bak files thank you
    set.swapfile = false        -- No swap file thank you
    set.joinspaces = false      -- No extra space after '.' when joining lines
    set.wrap = false            -- No line wrap please
    set.writebackup = false     -- No .bak files even before writing
    set.number = true           -- Show absolute line numbers
    set.relativenumber = true   -- Show relative line numbers
    set.scrolloff = 10          -- Leave lines above/below cursor
    set.shiftwidth = 4          -- Set indentation depth to 4 columns
    set.sidescroll = 1          -- Ensure smooth side-scrolling
    set.sidescrolloff = 1       -- Don't select edge characters while side-scrolling
    set.softtabstop = 4         -- Backspace over 4-space tabs together
    set.splitbelow = true       -- Always split below current buffer
    set.splitright = true       -- Always split right of current buffer
    set.tabstop = 4             -- Set tabular length to 4 columns
    set.termguicolors = true    -- Enable RGB color in the TUI
    set.textwidth = 0           -- Do not automatically wrap text when pasting long lines
    set.timeoutlen = 250        -- Use less timeout
    set.ttimeoutlen = 10        -- Use less keycode timeout
    set.updatetime = 500        -- Check file status every half second
    set.virtualedit = 'block'   -- Allow selecting over non-existant characters in visual block mode

    -- Use UTF-8 encoding
    set.encoding = 'utf-8'
    -- Use vertical diff splits by default
    set.diffopt = { 'internal', 'filler', 'vertical' }
    -- View sessions should save appropriate things (not local options!)
    set.viewoptions = { 'cursor', 'folds', 'slash', 'unix' }
    -- See ALL the characters
    set.list = true
    set.listchars = { tab='→ ', nbsp='␣', trail='·', extends='⟩', precedes='⟨' }
    set.showbreak = '↪ '
    -- Enable auto-completion menu
    set.completeopt = { 'menuone', 'preview', 'noselect' }
    -- Set terminal title
    set.title = true
    set.titlelen = 40
    set.titlestring = '%f%=%<(%l/%L:%P)'        -- See "statusline" help for item defs
    -- Configure folding
    set.foldlevelstart = 99                     -- Open files with open folds
    set.foldmethod = 'expr'
    set.foldexpr = 'nvim_treesitter#foldexpr()' -- Use treesitter for folding rules
end

function M.set_autocommands()
    local augroup = vim.api.nvim_create_augroup
    local autocmd = vim.api.nvim_create_autocmd

    -- Automatically show absolute numbering while in insert mode
    augroup('InsertRelNum', { clear = true })
    autocmd('InsertEnter', { command = 'set norelativenumber', group = 'InsertRelNum' })
    autocmd('InsertLeave', { command = 'set relativenumber', group = 'InsertRelNum' })

    -- Highlight characters in column 90 and columns 120+
    augroup('ColorCol', { clear = true })
    autocmd('ColorScheme', {
        command = 'highlight ColorColumn ctermbg=darkred guibg=darkred',
        group = 'ColorCol',
    })
    autocmd('ColorScheme', {
        command = 'match ColorColumn /\\%>89v.*\\%<91v/',
        group = 'ColorCol',
    })
    autocmd('ColorScheme', {
        command = '2match ColorColumn /\\%>120v/',
        group = 'ColorCol',
    })
end

function M.init()
    for _, method in ipairs(M.ALL) do
        M[method]()
    end
end

return M

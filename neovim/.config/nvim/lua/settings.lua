-- Global settings

-- vim.o is like using :set
local cmd = vim.cmd

local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= "o" then
    scopes["o"][key] = value
  end
end

--
-- Look and feel
--
cmd "syntax on" -- Syntax highlighting
opt("o", "termguicolors", true) -- enable true color mode in terminal
opt("o", "title", true) -- Show filename in titlebar
opt("o", "showmatch", true) -- Show matching brackets.
opt("o", "mat", 5) -- Bracket blinking.
opt("o", "colorcolumn", "80,100") -- Mark column 80
opt("w", "signcolumn", "yes")

-- hide line numbers in terminal windows
vim.api.nvim_exec([[
   au BufEnter term://* setlocal nonumber
]], false)

--
-- General options
--
opt("o", "mouse", "a") -- enable mouse support
opt("o", "hidden", true) -- hide buffers instead of closing
-- opt("o", "nobackup", true) -- no backup files
-- opt("o", "nowritebackup", true) -- no backup files
-- opt("o", "noswapfile", true) -- no swap file
opt("o", "autoread", true) -- Automatically reload files on changes

opt("o", "timeoutlen", 250) -- Time to wait after ESC (default causes an annoying delay)
opt("o", "history", 256) -- History buffer
opt("o", "undolevels", 99) -- Max undo levels
-- opt("o", "encoding=utf-8", true) -- Set encoding type

opt("o", "clipboard", "unnamedplus") -- copy to system clipboard
opt("o", "number", true) --line numbers
opt("o", "numberwidth", 2) --line numbers
opt("o", "cursorline", true) -- highlights current line
opt("o", "scrolloff", 5) -- Number of lines to below cursor to start auto scroll

--
-- Search Options
--
opt("o", "ignorecase", true) -- case insensitive search
opt("o", "smartcase", true) -- Case sensitive if theres a capital letter

--
-- Tab spacing
--
opt("o", "tabstop", 2) -- Case sensitive if theres a capital letter
opt("o", "shiftwidth", 2) -- Case sensitive if theres a capital letter
opt("o", "expandtab", true) -- convert tabs to whitepsace
opt("o", "softtabstop", 2) -- Make backspace go back 2 spaces

-- file extension specific tabbing
-- Python uses 4 tabs as standard
vim.cmd([[autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4]])

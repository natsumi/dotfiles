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

--
-- General options
--
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
opt("o", "number", true)  --line numbers
opt("o", "numberwidth", 2)  --line numbers
opt("o", "cursorline", true) -- highlights current line
opt("o", "scrolloff", 5) -- Number of lines to below cursor to start auto scroll
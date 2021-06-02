-- Global settings

-- vim.o is like using :set
local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= "o" then
        scopes["o"][key] = value
    end
end

opt("o", "clipboard", "unnamedplus") -- copy to system clipboard
opt("o", "number", true)  --line numbers
opt("o", "cursorline", true) -- highlights current line
opt("o", "scrolloff", 5) -- Number of lines to below cursor to start auto scroll
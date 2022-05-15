-- MAPPINGS
local M = {}

-- add this table only when you want to disable default keys
-- M.disabled = {
--   n = {
--       ["<leader>h"] = "",
--       ["<C-s>"] = ""
--   }
-- },

-- Mapping Format
--  ["keys"] = {"action", "icon  mapping description"}

-- map(
--     "n",
--     "<C-p>",
--     -- [[<cmd>lua require('telescope.builtin').find_files({find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<CR>]] =
--     -- [[<cmd>Telescope find_files<cr>]] =
--     [[<cmd>Telescope find_files find_command=rg,--hidden,--files<CR>]] =
--     opt
-- )
-- '["<leader>q", ":q <CR>", opt)

-- DAP
M.dap =  {
   n = {
 [ "<leader>dct" ] =  { '<cmd>lua require"dap".continue()<CR>', "DAP Continue" },
 [ "<leader>dsv" ] = { '<cmd>lua require"dap".step_over()<CR>', "DAP Step Over" },
 [ "<leader>dsi" ] =  { '<cmd>lua require"dap".step_into()<CR>', "DAP Step Into" },
 [ "<leader>dso" ] =  { '<cmd>lua require"dap".step_out()<CR>', "DAP Step Out" },
 [ "<leader>dtb" ] =  { '<cmd>lua require"dap".toggle_breakpoint()<CR>', "DAP Toogle Breakpoint" },

 [ "<leader>dsc" ] =  { '<cmd>lua require"dap.ui.variables".scopes()<CR>', "DAP Variable Scope" },
 [ "<leader>dhh" ] =  { '<cmd>lua require"dap.ui.variables".hover()<CR>', "DAP Variable Hover" },

 [ "<leader>duh" ] =  { '<cmd>lua require"dap.ui.widgets".hover()<CR>', "DAP Wiedget Hover" },
 [ "<leader>duf" ] =  { "<cmd>lua local widgets=require'dap.ui.widgets';widgets.centered_float(widgets.scopes)<CR>",  "DAP Widgets" },

 [ "<leader>dsbr" ] =  { '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>', "DAP Set Breakpoint" },
 [ "<leader>dsbm" ] =  { '<cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>', "DAP Breakpoint Message " },
 [ "<leader>dro" ] =  { '<cmd>lua require"dap".repl.open()<CR>', "DAP Repl Open" },
 [ "<leader>drl" ] =  { '<cmd>lua require"dap".repl.run_last()<CR>', "DAP Repl Run Last" },
   },

   v = {
 [ "<leader>dhv" ] =  { '<cmd>lua require"dap.ui.variables".visual_hover()<CR>', "DAP Variable Visual Hover" },
   },
}

-- DAP Telescope
M.telescope =  {

["<leader>dcc"] = {'<cmd>lua require"telescope".extensions.dap.commands{}<CR>'},
["<leader>dco"] = {'<cmd>lua require"telescope".extensions.dap.configurations{}<CR>'},
["<leader>dlb"] = {'<cmd>lua require"telescope".extensions.dap.list_breakpoints{}<CR>'},
["<leader>dv"] = {'<cmd>lua require"telescope".extensions.dap.variables{}<CR>'},
["<leader>df"] = {'<cmd>lua require"telescope".extensions.dap.frames{}<CR>'},
-- DAP UI
["<leader>dui"] = {'<cmd>lua require"dapui".toggle()<CR>'},
}

return M
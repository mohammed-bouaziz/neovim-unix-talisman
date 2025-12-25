local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.keymap.set

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Save file
keymap("n", "<leader>w", ":w<CR>", opts)

-- Quit
keymap("n", "<leader>q", ":q<CR>", opts)

-- Force Quit (Space + Q)
keymap("n", "<leader>Q", ":q!<CR>", opts)

-- Better window navigation (Control + h/j/k/l)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Clear highlights (Space + h)
keymap("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts) -- Paste without losing copied text

-- Insert --
-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", opts)

-- Split window vertically (Space + v)
keymap("n", "<leader>v", ":vsplit<CR>", opts)

-- Split window horizontally (Space + s)
keymap("n", "<leader>s", ":split<CR>", opts)

-- Toggle File Explorer (Space + e)
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope Keymaps
-- Find files by name (Space + f)
keymap("n", "<leader>f", "<cmd>Telescope find_files<cr>", opts)

-- Search text inside files (Space + g) -> Requires ripgrep
keymap("n", "<leader>g", "<cmd>Telescope live_grep<cr>", opts)

-- List open buffers (Space + b)
keymap("n", "<leader>b", "<cmd>Telescope buffers<cr>", opts)

-- LSP Keymaps (Intelligence)
-- K: Hover documentation (like hovering mouse in VS Code)
keymap("n", "K", vim.lsp.buf.hover, opts)

-- gd: Go to definition
keymap("n", "gd", vim.lsp.buf.definition, opts)

-- gD: Go to declaration
keymap("n", "gD", vim.lsp.buf.declaration, opts)

-- gr: References (who uses this function?)
keymap("n", "gr", vim.lsp.buf.references, opts)

-- Space + r: Rename variable everywhere
keymap("n", "<leader>r", vim.lsp.buf.rename, opts)

-- Space + a: Code Action (Quick fix)
keymap("n", "<leader>a", vim.lsp.buf.code_action, opts)

-- ==========================================
--  COMPILE AND RUN (F5)
-- ==========================================

local function run_code()
  -- 1. Save the file first
  vim.cmd("write")

  -- 2. Get file details
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")            -- e.g., "main.c"
  local filename_no_ext = vim.fn.expand("%:r")   -- e.g., "main"
  local cmd = ""

  -- 3. Determine the command based on filetype
  if filetype == "python" then
    cmd = "python3 " .. filename
    
  elseif filetype == "c" then
    -- Compile with gcc, output to a binary, then run it
    cmd = "gcc " .. filename .. " -o " .. filename_no_ext .. " && ./" .. filename_no_ext
    
  elseif filetype == "cpp" then
    cmd = "g++ " .. filename .. " -o " .. filename_no_ext .. " && ./" .. filename_no_ext
    
  elseif filetype == "javascript" then
    cmd = "node " .. filename
    
  elseif filetype == "lua" then
    cmd = "lua " .. filename
    
  elseif filetype == "sh" then
    cmd = "bash " .. filename
    
  else
    print("No run command defined for filetype: " .. filetype)
    return
  end

  -- 4. Open a terminal in a horizontal split and run the command
  -- Change "split" to "vsplit" if you prefer a vertical window
  vim.cmd("split | term " .. cmd)
end

-- Map F5 to the function
keymap("n", "<F5>", run_code, opts)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- 1. Core utility
    "nvim-lua/plenary.nvim",

    -- 2. File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                sort = { sorter = "case_sensitive" },
                view = { width = 30 },
                renderer = { group_empty = true },
                filters = { dotfiles = false },
            })
        end,
    },

    -- 3. Telescope
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
                }
            })
        end
    },

    -- 4. treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false, -- Rewrite docs explicitly say lazy-loading is not supported
        build = ":TSUpdate",
        config = function()
            -- 1. Initialize the plugin (uses default install_dir)
            require("nvim-treesitter").setup({})

            -- 2. Install the specific parsers you want (Replaces 'ensure_installed')
            -- This runs asynchronously by default (replaces 'sync_install = false')
            require("nvim-treesitter").install({
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "javascript",
                "typescript",
                "html",
                "css",
                "bash",
                "python",
            })

            -- 3. Enable Highlighting and Indentation (Replaces 'highlight' and 'indent' keys)
            -- The new method requires hooking into the FileType autocommand
            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    -- Enable native Treesitter highlighting
                    local ok, _ = pcall(vim.treesitter.start)

                    -- Enable Treesitter-based indentation (experimental)
                    if ok then
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    -- LSP config
    -- plugins.lua

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()

            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "pyright", "ts_ls", "angularls", "lua_ls" },
                handlers = {
                    function(server_name)
                        local capabilities = require('cmp_nvim_lsp').default_capabilities()
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,
                }
            })

            -- =========================================================================
            --  DIAGNOSTIC CONFIGURATION (Updated for Neovim 0.10+)
            -- =========================================================================

            -- 1. Custom Colors (Keep these to ensure Red/Yellow visibility)
            vim.cmd([[
        highlight DiagnosticSignError guifg=#FF0000 ctermfg=Red
        highlight DiagnosticSignWarn  guifg=#FFFF00 ctermfg=Yellow
        highlight DiagnosticSignHint  guifg=#00FF00 ctermfg=Green
        highlight DiagnosticSignInfo  guifg=#00FFFF ctermfg=Cyan

        highlight DiagnosticVirtualTextError guifg=#FF0000 ctermfg=Red
        highlight DiagnosticVirtualTextWarn  guifg=#FFFF00 ctermfg=Yellow
      ]])

            -- 2. Config: behavior and signs (THE NEW WAY)
            vim.diagnostic.config({
                virtual_text = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                -- Define signs here instead of using sign_define
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "E",
                        [vim.diagnostic.severity.WARN] = "W",
                        [vim.diagnostic.severity.HINT] = "H",
                        [vim.diagnostic.severity.INFO] = "I",
                    },
                },
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })

            -- 3. AUTO-HOVER: Show diagnostic popup automatically when cursor stops
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
                callback = function()
                    vim.diagnostic.open_float(nil, { focus = false })
                end
            })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", -- Source for LSP
            "hrsh7th/cmp-buffer",   -- Source for text in buffer
            "hrsh7th/cmp-path",     -- Source for file paths
            "L3MON4D3/LuaSnip",     -- Snippet engine
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter to confirm
                    ['<Tab>'] = cmp.mapping(function(fallback)         -- Tab to go down
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback) -- Shift+Tab to go up
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' }, -- LSP suggestions
                    { name = 'luasnip' },  -- Snippets
                }, {
                    { name = 'buffer' },   -- Text in current file
                    { name = 'path' },     -- File paths
                })
            })
        end,
    },
    -- 8. Auto Pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        dependencies = { "hrsh7th/nvim-cmp" },
        config = function()
            require("nvim-autopairs").setup({
                check_ts = false, -- use treesitter to check for pairs
            })

            -- If you want to automatically add `(` after selecting a function or method
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )
        end,
    },
    -- 9. Commenting (gcc to comment line, gc + motion for blocks)
    {
        "numToStr/Comment.nvim",
        lazy = false,
        config = function()
            require("Comment").setup()
        end,
    },
    -- Auto-formatting
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "black" }, -- You need to install black (pip install black)
                    javascript = { "prettier" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end,
    },
    -- Git integration (Shows changes in the gutter)
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    },
    -- Status Line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- Custom "White & Blue" Theme
            local custom_theme = {
                normal = {
                    a = { fg = '#ffffff', bg = '#005faff', gui = 'bold' },          -- Blue box, White text (Mode)
                    b = { fg = '#005faff', bg = '#eeeeee' },                        -- Grey box, Blue text (Branch/Diff)
                    c = { fg = '#000000', bg = '#ffffff' },                         -- White bar, Black text (Filename)
                },
                insert = { a = { fg = '#ffffff', bg = '#00d700', gui = 'bold' } },  -- Green for Insert
                visual = { a = { fg = '#ffffff', bg = '#d700d7', gui = 'bold' } },  -- Purple for Visual
                replace = { a = { fg = '#ffffff', bg = '#ff0000', gui = 'bold' } }, -- Red for Replace

                inactive = {
                    a = { fg = '#000000', bg = '#ffffff' },
                    b = { fg = '#000000', bg = '#ffffff' },
                    c = { fg = '#000000', bg = '#ffffff' },
                },
            }

            require('lualine').setup({
                options = {
                    theme = custom_theme,
                    component_separators = '|',
                    section_separators = { left = '', right = '' }, -- Rounded separators (requires a Nerd Font)
                    globalstatus = true, -- One single bar for all split windows
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { 'filename' },
                    lualine_x = { 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
            })
        end,
    },
})

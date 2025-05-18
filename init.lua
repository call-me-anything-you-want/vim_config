-- some requirements that needs to be installed manually as listed bellow:
-- * any c compiler (if missing in linux, can be installed with `sudo apt install build-essential`)
-- * npm (if missing in linux, can be installed with `sudo apt install npm`)
-- * nodejs (if missing in linux, can be installed with `sudo apt install nodejs`)
-- * xclip (if missing in linux, can be installed with `sudo apt install xclip`)
-- * lua 5.1 (if missing in linux, can be installed with `sudo apt install lua5.1`)
-- * luarocks (if missing in linux, can be installed with `sudo apt install luarocks`)
-- * ripgrep (if missing in linux, can be installed with `sudo apt install ripgrep`)
-- * neovim in npm (if missing in linux, can be installed with `sudo npm install -g neovim`)
-- * fd-find (if missing in linux, can be installed with `sudo apt install fd-find`)


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- line number
vim.wo.number = true
vim.wo.relativenumber = true
-- indent
vim.wo.cursorline = true
vim.o.tabstop = 4
vim.bo.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4
vim.o.expandtab = true
vim.bo.expandtab = true
vim.o.autoindent = true
vim.bo.autoindent = true
vim.o.smartindent = true
-- font
vim.o.guifont = 'Lilex Nerd Font Mono:h13'

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        {
            "neanias/everforest-nvim",
            version = false,
            lazy = false,
            priority = 1000, -- make sure to load this before all the other start plugins
            config = function()
                require("everforest").setup({
                    -- Your config here
                })
                vim.cmd([[colorscheme everforest]])
            end,
        },
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            opts = {
                theme = "everforest"
            }
        },
        {
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
                "MunifTanjim/nui.nvim",
                -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
            }
        },
        {
            'romgrk/barbar.nvim',
            dependencies = {
                -- 'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
                'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
            },
            init = function() vim.g.barbar_auto_setup = false end,
            opts = {},
            -- version = '^1.0.0', -- optional: only update when a new 1.x version is released
        },
        {
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            opts = {}
        },
        {
            "L3MON4D3/LuaSnip",
            -- follow latest release.
            version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
            -- install jsregexp (optional!).
            -- build = "make install_jsregexp"
        },
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = {
                "nvim-lua/plenary.nvim", -- required
                -- ripgrep, suggested
                -- fd, optinal
                "nvim-treesitter/nvim-treesitter", -- optional, for finder and preview
                "nvim-tree/nvim-web-devicons", -- optional
            }
        },
        {
            "kmontocam/nvim-conda",
            dependencies = {
                "nvim-lua/plenary.nvim"
            },
            ft = 'python',
        },
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
                "hrsh7th/cmp-nvim-lsp"
            },
            lazy = false,
            config = function()
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

                require('mason').setup()
                local mason_lspconfig = require 'mason-lspconfig'
                local lspconfig = require("lspconfig")

                local function set_up_go_to_definition_keymap(client, bufnr)
                    local opts = { noremap = true, silent = true }
                    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
                end

                mason_lspconfig.setup {
                    ensure_installed = {
                        "pyright",
                    },
                    handlers = {
                        function (server_name)
                            local opts = {
                                on_attach = set_up_go_to_definition_keymap,
                                capabilities = capabilities,
                            }
                            lspconfig[server_name].setup(opts)
                        end
                    }
                }
                lspconfig.pyright.setup {
                    capabilities = capabilities,
                }

            end
        },
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "L3MON4D3/LuaSnip",
                "saadparwaiz1/cmp_luasnip"
            },
            config = function()
                local has_words_before = function()
                    unpack = unpack or table.unpack
                    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                end

                local cmp = require('cmp')
                local luasnip = require('luasnip')

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end
                    },
                    window = {
                        completion = cmp.config.window.bordered(),
                        documentation = cmp.config.window.bordered(),
                    },
                    mapping = cmp.mapping.preset.insert ({
                        ["<Tab>"] = cmp.mapping(
                            function(fallback)
                                if cmp.visible() then
                                    cmp.select_next_item()
                                elseif luasnip.expand_or_jumpable() then
                                    luasnip.expand_or_jump()
                                elseif has_words_before() then
                                    cmp.complete()
                                else
                                    fallback()
                                end
                            end,
                            { "i", "s" }
                        ),
                        ["<s-Tab>"] = cmp.mapping(
                            function(fallback)
                                if cmp.visible() then
                                    cmp.select_prev_item()
                                elseif luasnip.jumpable(-1) then
                                    luasnip.jump(-1)
                                else
                                    fallback()
                                end
                            end,
                            { "i", "s" }
                        ),
                        ["<c-e>"] = cmp.mapping.abort(),
                        ["<CR>"] = cmp.mapping.confirm({ select=true }),
                    }),
                    sources = cmp.config.sources(
                        {
                            { name = "nvim_lsp" },
                            { name = "luasnip" },
                        },
                        {
                            {name = 'buffer'},
                        }
                    ),
                })

                -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
                cmp.setup.cmdline(
                    { '/', '?' },
                    {
                        mapping = cmp.mapping.preset.cmdline(),
                        sources = { { name = 'buffer' } }
                    }
                )

                -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
                cmp.setup.cmdline(
                    ':',
                    {
                        mapping = cmp.mapping.preset.cmdline(),
                        sources = cmp.config.sources(
                            { { name = 'path' } },
                            { { name = 'cmdline' } }
                        ),
                        matching = { disallow_symbol_nonprefix_matching = false }
                    }
                )
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            version = false,
            build = function()
                require("nvim-treesitter.install").update({ with_sync = true })
            end,
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = {
                        "python",
                        "vimdoc",
                        "lua"
                    },
                    auto_install = true,
                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = false
                    },
                    incremental_selection = {
                        enable = true,
                        keymaps = {
                            init_selection = "gnn",
                            node_incremental = "grn",
                            scope_incremental = "grc",
                            node_decremental = "grm",
                        }
                    }
                })
            end
        },
        {
            'echasnovski/mini.nvim',
            version = false,
            config = function()
                require("mini.pairs").setup({})

                -- change to surround.vim key mapping
                require("mini.surround").setup({
                    mappings = {
                        add = "ys", -- defaults to "sa"
                        delete = "ds", -- defaults to "sd"
                        find = "", -- defaults to "sf"
                        find_left = "", -- defaults to "sF"
                        highlight = "", -- defaults to "sh"
                        replace = "cs", -- defaults to "sr"
                        update_n_lines = "" -- defaults to "sn"
                    }
                })
            end
        },
        {
            'smoka7/hop.nvim',
            version = "*",
            opts = {
                keys = 'etovxqpdygfblzhckisuran'
            }
        },
        {
            'MeanderingProgrammer/render-markdown.nvim',
            dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
            ---@module 'render-markdown'
            ---@type render.md.UserConfig
            ft = 'markdown',
            opts = {},
        },
        {
            'CRAG666/code_runner.nvim',
            config = function()
                require('code_runner').setup({
                    filetype = {
                        java = {
                            "cd $dir &&",
                            "javac $fileName &&",
                            "java $fileNameWithoutExt"
                        },
                        python = "python3 -u",
                        typescript = "deno run",
                        rust = {
                            "cd $dir &&",
                            "rustc $fileName &&",
                            "$dir/$fileNameWithoutExt"
                        },
                        c = function(...)
                            c_base = {
                                "cd $dir &&",
                                "gcc $fileName -o",
                                "/tmp/$fileNameWithoutExt",
                            }
                            local c_exec = {
                                "&& /tmp/$fileNameWithoutExt &&",
                                "rm /tmp/$fileNameWithoutExt",
                            }
                            vim.ui.input({ prompt = "Add more args:" }, function(input)
                                c_base[4] = input
                                vim.print(vim.tbl_extend("force", c_base, c_exec))
                                require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
                            end)
                        end,
                    },
                })
            end
        },
        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            keys = {
                {
                    "<leader>?",
                    function()
                        require("which-key").show({ global = false })
                    end,
                    desc = "Buffer Local Keymaps (which-key)",
                },
            },
            config = function()
                local wk = require("which-key")
                wk.setup({})

                -- Lazy
                wk.add({
                    { "<leader>L", "<cmd>Lazy<cr>", desc = "Open Lazy.nvim Pannel" }
                })

                -- NeoTree
                wk.add({
                    { "<leader>T", "<cmd>Neotree<cr>", desc = "Open File Tree (NeoTree)", mode = "n" },
                    -- add key maps related to <leader> here
                })

                -- Hop
                local hop = require('hop')
                local directions = require('hop.hint').HintDirection
                wk.add({
                    { "<leader><leader>", group = "hop" },
                    {
                        "<leader><leader>f",
                        function()
                            hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
                        end,
                        remap = true,
                        desc = "hint_char1_forward (hop)"
                    },
                    {
                        "<leader><leader>s",
                        function()
                            hop.hint_char2({ direction = directions.AFTER_CURSOR, current_line_only = false })
                        end,
                        remap = true,
                        desc = "hint_char2_forward (hop)"
                    },
                    {
                        "<leader><leader>F",
                        function()
                            hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
                        end,
                        remap = true,
                        desc = "hint_char1_backward (hop)"
                    },
                    {
                        "<leader><leader>S",
                        function()
                            hop.hint_char2({ direction = directions.BEFORE_CURSOR, current_line_only = false })
                        end,
                        remap = true,
                        desc = "hint_char2_backward (hop)"
                    },
                    {
                        "<leader><leader>w",
                        "<cmd>HopWord<cr>",
                        desc = "hop word (hop)",
                        remap = true
                    },
                    {
                        "<leader><leader>l",
                        "<cmd>HopLine<cr>",
                        desc = "hop line (hop)",
                        remap = true
                    },
                    {
                        "<leader><leader>L",
                        "<cmd>HopLineStart<cr>",
                        desc = "hop line start (hop)",
                        remap = true
                    },
                })

                -- telescope
                local builtin = require("telescope.builtin")
                wk.add({
                    { "<leader>t", group = "telescope" },
                    {
                        "<leader>tf",
                        builtin.find_files,
                        desc = "telescope find files",
                        mode = "n"
                    },
                    {
                        "<leader>tg",
                        builtin.live_grep,
                        desc = "telescope live grep",
                        mode = "n"
                    },
                    {
                        "<leader>tb",
                        builtin.buffers,
                        desc = "telescope find in buffer",
                        mode = "n"
                    },
                    {
                        "<leader>th",
                        builtin.help_tags,
                        desc = "telescope help tags",
                        mode = "n"
                    }
                })
                
                -- code runner
                wk.add({
                    { "<leader>r", group = "code runner" },
                    {
                        "<leader>rr",
                        "<cmd>RunCode<cr>",
                        desc = "Runs based on file type",
                    },
                    {
                        "<leader>rf",
                        "<cmd>RunFile<cr>",
                        desc = "Run the current file",
                    },
                    {
                        "<leader>rt",
                        "<cmd>RunFile tab<cr>",
                        desc = "Run the current file in a tab",
                    },
                    {
                        "<leader>rc",
                        "<cmd>RunClose<cr>",
                        desc = "Close runner",
                    }
                })

                -- open .vimrc or init.lua
                wk.add({
                    {
                        "<leader>Cfg",
                        "<cmd>edit $MYVIMRC<cr>",
                        desc = "open .vimrc or init.lua file",
                    },
                })
                -- add key maps related to <leader> here
            end
        }
        -- add your plugins here
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})

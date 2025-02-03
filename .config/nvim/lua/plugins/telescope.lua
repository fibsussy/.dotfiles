return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-fzf-native.nvim',
            'nvim-telescope/telescope-symbols.nvim',
        },
        config = function()
            -- Configure Telescope
            require('telescope').setup({
                defaults = {
                    layout_strategy = "horizontal",
                    layout_config = {
                        preview_width = 0.65,
                        horizontal = {
                            size = {
                                width = "95%",
                                height = "95%",
                            },
                        },
                    },
                    pickers = {
                        find_files = {
                            theme = "dropdown",
                        },
                    },
                    mappings = {
                        i = {
                            ['<C-u>'] = false,
                            ['<C-d>'] = false,
                            ["<C-j>"] = require('telescope.actions').move_selection_next,
                            ["<C-k>"] = require('telescope.actions').move_selection_previous,
                        },
                    },
                },
            })

            -- Load extensions
            pcall(require('telescope').load_extension, 'fzf')

            -- Set keymaps using mappings module
            local M = require("core.mappings")
            M.map('n', '<leader>?', '<cmd>lua require("telescope.builtin").oldfiles()<cr>', { desc = '[?] Find recently opened files' })
            M.map('n', '<leader>/', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = true })<cr>]], { desc = '[/] Fuzzily search in current buffer' })
        end,
        init = function()
            local M = require("core.mappings")
            M.map('n', '<leader>ff', '<cmd>lua require("telescope.builtin").find_files()<cr>', { desc = '[S]earch [F]iles' })
            M.map('n', '<leader>fw', '<cmd>lua require("telescope.builtin").grep_string()<cr>', { desc = '[S]earch current [W]ord' })
            M.map('n', '<leader>fg', '<cmd>lua require("telescope.builtin").live_grep()<cr>', { desc = '[S]earch by [G]rep' })
            M.map('n', '<leader>fd', '<cmd>lua require("telescope.builtin").diagnostics()<cr>', { desc = '[S]earch [D]iagnostics' })
            M.map('n', '<leader>fb', '<cmd>lua require("telescope.builtin").buffers()<cr>', { desc = '[ ] Find existing buffers' })
            M.map('n', '<leader>fS', '<cmd>lua require("telescope.builtin").git_status()<cr>', { desc = 'Search git status' })
            M.map('n', '<leader>fm', ':Telescope harpoon marks<CR>', { desc = 'Harpoon [M]arks' })
            M.map('n', '<Leader>fr', '<CMD>lua require("telescope").extensions.git_worktree.git_worktrees()<CR>', { silent = true })
            M.map('n', '<Leader>fR', '<CMD>lua require("telescope").extensions.git_worktree.create_git_worktree()<CR>', { silent = true })
            M.map('n', '<Leader>fn', '<CMD>lua require("telescope").extensions.notify.notify()<CR>', { silent = true })
            M.map('n', 'st', ':TodoTelescope<CR>', { noremap = true })
            M.map('n', '<Leader><tab>', '<Cmd>lua require("telescope.builtin").commands()<CR>', { noremap = false })
        end,
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable 'make' == 1,
    },
    'nvim-telescope/telescope-symbols.nvim',
}

return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-fzf-native.nvim',
            'nvim-telescope/telescope-symbols.nvim',
        },
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                layout_config = {
                    preview_width = 0.65,
                    horizontal = { size = { width = "95%", height = "95%" } },
                },
                pickers = { find_files = { theme = "dropdown" } },
                mappings = {
                    i = {
                        ['<C-u>'] = false,
                        ['<C-d>'] = false,
                        ["<C-j>"] = require('telescope.actions').move_selection_next,
                        ["<C-k>"] = require('telescope.actions').move_selection_previous,
                    },
                },
            },
        },
        config = function()
            pcall(require('telescope').load_extension, 'fzf')
        end,
        init = function()
            vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Telescope: Find files' })
            vim.keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<cr>', { desc = 'Telescope: Find current word' })
            vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Telescope: Find by grep' })
            vim.keymap.set('n', '<leader>fd', '<cmd>Telescope diagnostics<cr>', { desc = 'Telescope: Find diagnostics' })
            vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Telescope: Find buffers' })
            vim.keymap.set('n', '<leader>fS', '<cmd>Telescope git_status<cr>', { desc = 'Telescope: Find git status' })
            vim.keymap.set('n', '<leader>fh', '<cmd>Telescope harpoon marks<cr>', { desc = 'Telescope: Harpoon Marks' })
            vim.keymap.set('n', '<leader>fr', '<cmd>Telescope git_worktree git_worktrees<cr>', { desc = 'Telescope: Git Worktrees' })
            vim.keymap.set('n', '<leader>fR', '<cmd>Telescope git_worktree create_git_worktree<cr>', { desc = 'Telescope: Create Git Worktree' })
            vim.keymap.set('n', '<leader>fn', '<cmd>Telescope notify notify<cr>', { desc = 'Telescope: Notify' })
            vim.keymap.set('n', 'st', '<cmd>TodoTelescope<cr>', { desc = 'Telescope: Todo' })
            vim.keymap.set('n', '<leader><tab>', '<cmd>Telescope commands<cr>', { desc = 'Telescope: Commands' })
            vim.keymap.set('n', '<leader>?', '<cmd>Telescope keymaps<cr>', { desc = 'Telescope: Keymaps' })
            vim.keymap.set('n', '<leader>/', '<cmd>Telescope current_buffer_fuzzy_find<cr>', { desc = 'Telescope: Fuzzy search current buffer' })
        end,
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable 'make' == 1,
    },
    'nvim-telescope/telescope-symbols.nvim',
}

return {
    "hrsh7th/nvim-cmp",
    config = function(_, opts)
        local cmp = require "cmp"
        cmp.setup(opts)
    end,
    opts = function()
        local cmp = require "cmp"
        local opts = require "nvchad.configs.cmp"

        opts.mapping["<Up>"] = cmp.mapping.select_prev_item()
        opts.mapping["<Down>"] = cmp.mapping.select_next_item()

        local entry_filter = function(entry, ctx)
            local blacklist = { "color_eyre::owo_colors" }
            local full_import_path = entry.completion_item.data and entry.completion_item.data.imports and entry.completion_item.data.imports[1] and entry.completion_item.data.imports[1].full_import_path
            if full_import_path then
                for _, word in ipairs(blacklist) do
                    if full_import_path:match(word) then
                        return false
                    end
                end
            end
            return true
        end

        opts.sources = opts.sources or {}
        for _, source in ipairs(opts.sources) do
            source.entry_filter = entry_filter
        end

        local compare = require('cmp.config.compare')
        opts.sorting = {
            priority_weight = 2,
            comparators = {
                function(entry1, entry2)
                    local kind_priority = {
                        Field = 1,
                        EnumMember = 1,
                        Method = 2,
                        Variable = 3,
                        Enum = 4,
                        Struct = 5,
                        Function = 6,
                        Text = 7,
                        Snippet = 99999
                    }
                    local kind1 = entry1:get_kind()
                    local kind2 = entry2:get_kind()
                    local kind1_priority = kind_priority[kind1] or 100
                    local kind2_priority = kind_priority[kind2] or 100
                    if kind1_priority < kind2_priority then
                        return true
                    elseif kind1_priority > kind2_priority then
                        return false
                    end
                    return nil
                end,
                compare.locality,
                compare.recently_used,
                compare.score,
                compare.offset,
                compare.order,
            }
        }

        return opts
    end,
}

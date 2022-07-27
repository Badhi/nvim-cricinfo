local summary = require 'nvim-cricinfo.summary'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require 'telescope.config'
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"


local function nvim_cricinfo(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = 'cricinfo matches',
        finder = finders.new_table {
            results = summary.get_items(),
            entry_maker = function (entry)
                return
                {
                    value = entry,
                    display = entry.name,
                    ordinal = entry.id
                }
            end
        },
        attach_mappings = function (prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                require'nvim-cricinfo'.init({match_id = selection.value.id})
            end
            )
            return true
        end
    }):find()
end

return {
    cric_info = nvim_cricinfo
}

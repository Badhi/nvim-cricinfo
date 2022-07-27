local curl = require'plenary.curl'

local match_id = 1317901
local match_url = 'https://www.espncricinfo.com/matches/engine/match/%d.json'
local timer
local current_status

local function timer_hit()
    local res = curl.request{url = string.format(match_url, match_id)}
    if res.status == 200 then
        current_status = vim.fn.json_decode(res.body)
    end
end

local function stop_status()
    if timer then
        timer:close()
    end
end

local function start_timer()
    timer = vim.loop.new_timer()
    timer:start(100, 20000, vim.schedule_wrap(timer_hit))
end

local function init(setup)
    match_id = setup and setup.match_id or match_id
    start_timer()
end


local function get_summary()
    if current_status then
        return current_status.match.current_summary_abbreviation
    end
end


return {
    init = init,
    get_summary = get_summary,
    stop_status = stop_status,
}

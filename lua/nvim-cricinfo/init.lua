local curl = require'plenary.curl'

local summary

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

local scores_url = 'http://static.cricinfo.com/rss/livescores.xml'
local summary = {}

local title_tag = '<title>'
local link_tag = '<link>'
local item_tag = '<item>'

local function fetch()
    local res = curl.request { url = scores_url }
    if res.status == 200 then
        local lines = {}
        local item_started = false
        local match
        for s in res.body:gmatch("[^\r\n]+") do
            if string.sub(s, 1, string.len(item_tag)) == item_tag then
                item_started = true
            end

            if item_started then
                if string.sub(s, 1, string.len(title_tag)) == title_tag then
                    for a, b in s:gmatch(".*<title>(.*)</title>.*") do
                        match = {name = a}
                    end
                elseif  string.sub(s, 1, string.len(link_tag)) == link_tag then
                    for a, b in s:gmatch(".*match/(%d+).html.*") do
                        match.id = tonumber(a)
                        table.insert(summary, match)
                    end
                end
            end
        end
        print(vim.inspect(summary))
    end
end

return {
    init = init,
    get_summary = get_summary,
    stop_status = stop_status,
    test_fetch = fetch,
}

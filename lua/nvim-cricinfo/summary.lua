local curl = require'plenary.curl'

local scores_url = 'http://static.cricinfo.com/rss/livescores.xml'
local summary = {}

local title_tag = '<title>'
local link_tag = '<link>'
local item_tag = '<item>'

local function get_items()
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
                        a = string.gsub(a, "amp;", "")
                        print(a)
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
        return summary
    end
end

return {
    get_items = get_items
}


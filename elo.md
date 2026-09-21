local K = 32  -- how much a single result can move a rating; higher = more volatile

function MS.UpdateElo(winnerItem, loserItem)
    local winner = MS_data[winnerItem]
    local loser  = MS_data[loserItem]

    -- expected score: probability winner "should" have won, based on current ratings
    local expectedWinner = 1 / (1 + 10 ^ ((loser.rating - winner.rating) / 400))
    local expectedLoser  = 1 - expectedWinner

    winner.rating = winner.rating + K * (1 - expectedWinner)
    loser.rating  = loser.rating  + K * (0 - expectedLoser)

    winner.comparisons = winner.comparisons + 1
    loser.comparisons  = loser.comparisons + 1
    winner.wins   = winner.wins + 1
    loser.losses  = loser.losses + 1
    winner.lastShown = GetTime()
    loser.lastShown  = GetTime()
end



function MS.PickNextPair()
    local items = {}
    for item in pairs(MS_data) do table.insert(items, item) end

    -- bias toward under-compared items
    table.sort(items, function(a, b)
        return MS_data[a].comparisons < MS_data[b].comparisons
    end)

    local poolSize = math.min(10, #items)  -- take the 10 least-compared as the pool
    local first = items[math.random(poolSize)]

    -- from the rest, pick whichever is closest in rating to `first`
    local bestMatch, bestDiff = nil, math.huge
    for _, item in ipairs(items) do
        if item ~= first then
            local diff = math.abs(MS_data[item].rating - MS_data[first].rating)
            if diff < bestDiff then
                bestMatch, bestDiff = item, diff
            end
        end
    end

    return first, bestMatch
end



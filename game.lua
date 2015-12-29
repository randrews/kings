function shuffle() -- return a shuffled deck
    local cards = {}
    local deck = {}

    for _, suit in ipairs{'h','s','c','d'} do
        for rank = 2, 10 do
            table.insert(cards, suit .. rank)
        end

        for _, rank in ipairs{'a','j','q','k'} do
            table.insert(cards, suit .. rank)
        end
    end

    while #cards > 0 do
        table.insert(deck, table.remove(cards, math.random(#cards)))
    end

    return deck
end

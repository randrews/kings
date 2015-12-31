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

function start_game(layout)
    local game = {}

    -- Deck is a fresh shuffled deck, game.deck is that same deck
    -- minus kings
    local deck = shuffle()
    game.deck = {}

    while #deck > 0 do
        local card = table.remove(deck, 1)
        if card:sub(2,2) ~= 'k' then
            table.insert(game.deck, card)
        end
    end

    game.board = {}
    for y=0,8 do game.board[y] = {} end

    if layout == 'random' then -- Place kings randomly on the board
        local kings = {'hk', 'dk', 'ck', 'sk'}
        while #kings > 0 do
            local x, y = math.random(0,11), math.random(0,8)
            if not game.board[y][x] then
                game.board[y][x] = table.remove(kings, 1)
            end
        end
    elseif layout == 'corners' then -- Kings in the corners
        game.board[0][0] = 'hk'
        game.board[0][11] = 'ck'
        game.board[8][0] = 'sk'
        game.board[8][11] = 'dk'
    else -- Kings in the center, the default
        game.board[4][4] = 'hk'
        game.board[4][5] = 'sk'
        game.board[4][6] = 'ck'
        game.board[4][7] = 'dk'
    end

    game.hand = {}

    function game:draw()
        table.insert(self.hand, table.remove(self.deck, 1))
    end

    for n=1,4 do game:draw() end

    return game
end


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

function place_card(game, from, value, x, y) -- from is a table like {type='hand', x=1}
    game.board[y][x] = value
    if from.type == 'hand' then
        game.hand[from.x+1] = nil
    else
        game.board[from.y][from.x] = nil
    end
end

function legal_drops(game, card)
    local function matches(other)
        if not other then return true end -- everything matches an empty space
        if card:sub(1,1) == other:sub(1,1) then return true end -- same suit
        if card:sub(2,3) == other:sub(2,3) then return true end -- same value
        return false
    end

    local function adjacent(x,y)
        if x > 0 and game.board[y][x-1] then return true end
        if x < 11 and game.board[y][x+1] then return true end
        if y > 0 and game.board[y-1][x] then return true end
        if y < 8 and game.board[y+1][x] then return true end
    end

    local function neighbor_matches(x,y)
        if x > 0 and not matches(game.board[y][x-1]) then return false end
        if x < 11 and not matches(game.board[y][x+1]) then return false end
        if y > 0 and not matches(game.board[y-1][x]) then return false end
        if y < 8 and not matches(game.board[y+1][x]) then return false end
        return true
    end

    local drops = {}

    for y=0,8 do
        for x=0,11 do
            if game.board[y][x] == nil and neighbor_matches(x,y) and adjacent(x,y) then
                table.insert(drops, {x=x,y=y})
            end
        end
    end

    return drops
end

local cards, joker, backred, backgreen, backblue

local deck_coords = {
    {0, 3}, {1, 2}, {1, 1}, {1, 0}, {0, 9}, {0, 8}, {0, 7}, {0, 6}, {0, 5}, {0, 4}, {0, 2}, {0, 0}, {0, 1},
    {4, 3}, {2, 6}, {5, 1}, {5, 0}, {4, 9}, {4, 8}, {4, 7}, {4, 6}, {4, 5}, {4, 4}, {4, 2}, {4, 0}, {4, 1},
    {3, 0}, {3, 9}, {3, 8}, {3, 7}, {3, 6}, {3, 5}, {3, 4}, {3, 3}, {3, 2}, {3, 1}, {2, 9}, {2, 7}, {2, 8},
    {1, 7}, {5, 2}, {2, 5}, {2, 4}, {2, 3}, {2, 2}, {2, 1}, {2, 0}, {1, 9}, {1, 8}, {1, 6}, {1, 4}, {1, 5}
}

function love.load()
    love.filesystem.setIdentity('deck_png_creator');

    cards = love.graphics.newImage('cards.png')
    joker = love.graphics.newImage('cardJoker.png')
    backred = love.graphics.newImage('cardBack_red5.png')
    backgreen = love.graphics.newImage('cardBack_green5.png')
    backblue = love.graphics.newImage('cardBack_blue5.png')

    love.window.setMode(140*14, 190*4)
end

function draw_deck(canvas)
    local x, y = 0, 0
    local w, h = 140, 190

    for _, coords in ipairs(deck_coords) do
        local q = love.graphics.newQuad(coords[1]*w, coords[2]*h, w, h, cards:getWidth(), cards:getHeight())
        love.graphics.draw(cards, q, x, y, 0)
        x = x + w
        if x >= w*13 then
            x = 0
            y = y + h
        end
    end

    local q = love.graphics.newQuad(0, 0, w, h, joker:getWidth(), joker:getHeight())
    love.graphics.draw(backblue, q, w*13, 0, 0)
    love.graphics.draw(backred, q, w*13, h, 0)
    love.graphics.draw(backgreen, q, w*13, h*2, 0)
    love.graphics.draw(joker, q, w*13, h*3, 0)

end

function love.draw()
    draw_deck()
end

function love.mousepressed()
    love.graphics.push()
    local can = love.graphics.newCanvas()
    love.graphics.setCanvas(can)
    draw_deck()
    can:newImageData():encode("png", "deck.png")
    love.graphics.pop()

    print(love.filesystem.getSaveDirectory() .. "/deck.png")
end

require 'drawing'
require 'game'

CardsPng = nil

function love.load()
    CardsPng = love.graphics.newImage('deck.png')
end

game = start_game()

function love.draw()
     love.graphics.setBackgroundColor(65, 134, 89)
     draw_game(game)
end

function love.mousepressed(x, y, button, istouch)
    -- x, y = pixel_to_card(x, y)
    -- if #deck == 0 then
    --     board[y][x] = 'back'
    -- else
    --     board[y][x] = table.remove(deck, 1)
    -- end
end

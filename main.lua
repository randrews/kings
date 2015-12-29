require 'drawing'
require 'game'

CardsPng = nil

function love.load()
    CardsPng = love.graphics.newImage('deck.png')
end

board = {}
for y=0,8 do
    board[y] = {}
end
deck = shuffle()

function love.draw()
     love.graphics.setBackgroundColor(65, 134, 89)
     draw_board(board)
end

function love.mousepressed(x, y, button, istouch)
    x, y = pixel_to_card(x, y)
    if #deck == 0 then
        board[y][x] = 'back'
    else
        board[y][x] = table.remove(deck, 1)
    end
end

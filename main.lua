require 'drawing'
require 'game'
require 'ui'

CardsPng = nil

function love.load()
    CardsPng = love.graphics.newImage('deck.png')
end

function love.update(dt)
    fps = math.floor(1 / dt)
end

game = start_game()

function love.draw()
     love.graphics.setBackgroundColor(65, 134, 89)
     draw_game(game)
     love.graphics.setColor(255,255,255)
     love.graphics.print(tostring(fps), 5, 5)
end

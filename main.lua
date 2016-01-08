require 'sonnet'
require 'util'
require 'drawing'
require 'game'
require 'ui'

function love.load()
    game = Game()
    ui = UI(game)
    drawing = Drawing(game, ui)
    ui:install(love)
end

function love.update(dt)
    fps = math.floor(1 / dt)
end

function love.draw()
     love.graphics.setBackgroundColor(65, 134, 89)
     drawing:draw()
     love.graphics.setColor(255,255,255)
     love.graphics.print(tostring(fps), 5, 5)
end

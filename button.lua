Button = class('Button')

Button.all = {}

function Button:initialize(options)
    self.position = options.position
    self.size = options.size
    table.insert(Button.all, self)
end

function Button:draw(g)
    g.push()
    g.setColor(200, 200, 0)
    g.rectangle('line',
                self.position.x, self.position.y,
                self.size.x, self.size.y)
    g.pop()
end

function Button.draw(g)
    for _, button in ipairs(Button.all) do
        button:draw(g)
    end
end

Drawing = class('Drawing')

Drawing.static.CardsPng = love.graphics.newImage('deck.png')

function Drawing:initialize(game, ui)
    self.game = game
    self.ui = ui
    if ui then ui.drawing = self end
end

function Drawing:draw()
    self:draw_board(self.game.board)
    self:draw_hand(self.game.hand)
    self:draw_drops(self.game)
    self:draw_drag(self.game)
    self.cached_dimensions = nil
end

function Drawing:draw_drops(game, drag_state)
    if self.ui:dragging() then
        local drop = self:closest_drop()
        if not drop then return end

        local x,y,w,h = self:card_coords(drop.x, drop.y)
        love.graphics.setColor(55,115,76)
        love.graphics.push()
        love.graphics.translate(x,y)
        love.graphics.rectangle('fill', 2, 2, w-4, h-4, 3, 3)
        love.graphics.pop()
    end
end

function Drawing:closest_drop()
    local value = self.ui:dragged_value()
    local drops = self.game:legal_drops(value)
    local dragx, dragy = self:drag_card_coords()
    local mx, my = love.mouse.getPosition()

    local closest = nil
    local dist = math.huge
    for _, drop in ipairs(drops) do
        local x,y,w,h = self:card_coords(drop.x, drop.y)
        if intersect(x,y, w,h, dragx,dragy, w,h) then
            local curr_dist = distance(mx, my, x+w/2, y+h/2)
            if curr_dist < dist then
                curr_dist = dist
                closest = drop
            end
        end
    end

    return closest
end

function Drawing:drag_card_coords()
    local mx, my = love.mouse.getPosition()
    local sx, sy = self.ui:start()
    local dx, dy = mx - sx, my - sy

    local cx, cy
    if self.ui:card_type() == 'hand' then
        cx, cy = self:hand_coords(self.ui:card_coords()+1)
    else
        cx, cy = self:card_coords(self.ui:card_coords())
    end

    return cx+dx, cy+dy
end

function Drawing:draw_drag()
    if self.ui:dragging() then
        local value = self.ui:dragged_value()

        love.graphics.push()
        love.graphics.translate(self:drag_card_coords())
        self:draw_card(value)
        love.graphics.pop()
    end
end

function Drawing:draw_hand(hand, drag_state)
    love.graphics.push()

    local skip = nil
    if self.ui:dragging() and self.ui:card_type() == 'hand' then
        skip = self.ui:card_coords() + 1
    end

    local dims = self:card_dimensions()

    for n=1, 4 do
        local cx, cy, cw, ch = self:hand_coords(n)
        love.graphics.push()
        love.graphics.translate(cx, cy)

        if n == skip then self:draw_card(nil)
        else self:draw_card(hand[n]) end
        love.graphics.pop()
    end

    love.graphics.pop()
end

function Drawing:draw_board()
    local dims = self:card_dimensions()
    for y = 0, 8 do
        for x = 0, 11 do
            local cx, cy, cw, ch = self:card_coords(x, y)
            love.graphics.push()
            love.graphics.translate(cx, cy)
            self:draw_card(self.game.board[y][x])
            love.graphics.pop()
        end
    end
end

function Drawing:draw_card(card)
    local dims = self:card_dimensions()

    if card == nil then
        love.graphics.setColor(200, 200, 0)
        love.graphics.rectangle('line', 0, 0, dims.width, dims.height, 3, 3)
    else
        local suit = card:sub(1,1)
        local rank = card:sub(2,3)

        local quad = nil
        if suit == 'b' then
            quad = self:card_quad(13, 0)
        else
            local suits = { s=0, c=1, d=2, h=3 }
            local ranks = { a=0,
                            ['2']=1, ['3']=2, ['4']=3, ['5']=4, ['6']=5,
                            ['7']=6, ['8']=7, ['9']=8, ['10']=9,
                            j=10, q=11, k=12 }

            quad = self:card_quad(ranks[rank], suits[suit])
        end

        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(Drawing.static.CardsPng, quad, 0, 0, 0, dims.scale, dims.scale)
    end
end

function Drawing:card_quad(x, y)
    local w,h = 140, 190
    return love.graphics.newQuad(x*w, y*h, w, h,
                                 Drawing.static.CardsPng:getWidth(),
                                 Drawing.static.CardsPng:getHeight())
end

function Drawing:hand_coords(n)
    local dims = self:card_dimensions()
    local x,y = self:card_coords(n-1, 4)
    x = x + dims.status_left - dims.left
    return x, y, dims.width, dims.height
end

function Drawing:card_coords(x, y)
    local dims = self:card_dimensions()

    return dims.left + x*(dims.width+dims.spacing),
           dims.top + y*(dims.height+dims.spacing),
           dims.width, dims.height
end

function Drawing:pixel_to_card(x, y)
    local dims = self:card_dimensions()

    -- First, are we in the board or the hand or neither?
    if x >= dims.left and x <= dims.right then -- Board!
        x = x - dims.left + dims.spacing/2
        y = y - dims.top + dims.spacing/2
        return 'board', math.floor(x / (dims.width+dims.spacing)), math.floor(y / (dims.height+dims.spacing))
    elseif (x >= dims.status_left and x <= dims.status_right and
            y >= dims.hand_top and y <= dims.hand_bottom) then -- Hand
        x = x - dims.status_left + dims.spacing/2
        return 'hand', math.floor(x / (dims.width+dims.spacing))
    end
end

function Drawing:card_dimensions()
    if self.cached_dimensions then return self.cached_dimensions
    else
        local orig_w, orig_h = love.window.getMode()

        local h_margin = 10
        local h_divide = 30
        local v_margin = 10
        local spacing = 4

        w = orig_w - (2*h_margin) - h_divide - (14 * spacing)
        h = orig_h - (2*v_margin) - (8 * spacing)

        local card_width = math.floor(w/16)
        local card_height = math.floor(h/9)

        local h_scale = card_width / 140
        local v_scale = card_height / 190

        local scale = math.min(h_scale, v_scale)
        local scaled_card_width = math.floor(140 * scale)
        local scaled_card_height = math.floor(190 * scale)

        local top = math.floor((orig_h - 9*scaled_card_height - 8*spacing) / 2)
        local bottom = orig_h - top

        local left = math.floor((orig_w - 16*scaled_card_width - 14*spacing - h_divide)/2)
        local right = left + scaled_card_width * 12 + spacing * 11 -- Right edge of *board*

        local status_left = left + 12*scaled_card_width + 11*spacing + h_divide
        local status_right = status_left + scaled_card_width * 4 + spacing * 3

        local hand_top = top + scaled_card_height*4 + spacing*4
        local hand_bottom = top + scaled_card_height*5 + spacing*4

        self.cached_dimensions = {
            width = scaled_card_width,
            height = scaled_card_height,
            scale = scale,
            top = top,
            left = left,
            right = right,
            status_left = status_left,
            status_right = status_right,
            hand_top = hand_top,
            hand_bottom = hand_bottom,
            spacing = spacing }

        return self.cached_dimensions
    end
end

function draw_game(game)
    draw_board(game.board, drag_state)
    draw_hand(game.hand, drag_state)
    draw_drops(game, drag_state)
    draw_drag(game, drag_state)
end

function draw_drops(game, drag_state)
    if drag_state.dragging then
        local drop = closest_drop(game, drag_state)
        if not drop then return end

        local x,y,w,h = card_coords(drop.x, drop.y)
        love.graphics.setColor(55,115,76)
        love.graphics.push()
        love.graphics.translate(x,y)
        love.graphics.rectangle('fill', 2, 2, w-4, h-4, 3, 3)
        love.graphics.pop()
    end
end

function closest_drop(game, drag_state)
    local value = dragged_value(game)
    local drops = legal_drops(game, value)
    local dragx, dragy = drag_card_coords(drag_state)
    local mx, my = love.mouse.getPosition()

    local closest = nil
    local dist = math.huge
    for _, drop in ipairs(drops) do
        local x,y,w,h = card_coords(drop.x, drop.y)
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

function drag_card_coords(drag_state)
    local mx, my = love.mouse.getPosition()
    local dx, dy = mx - drag_state.startx, my - drag_state.starty

    local cx, cy
    if drag_state.target_card.type == 'hand' then
        cx, cy = hand_coords(drag_state.target_card.x+1)
    else
        cx, cy = card_coords(drag_state.target_card.x, drag_state.target_card.y)
    end

    return cx+dx, cy+dy
end

function draw_drag(game, drag_state)
    if drag_state.dragging then
        local value = dragged_value(game)

        love.graphics.push()
        love.graphics.translate(drag_card_coords(drag_state))
        draw_card(value)
        love.graphics.pop()
    end
end

function draw_hand(hand, drag_state)
    love.graphics.push()

    local skip = nil
    if drag_state.dragging == true and drag_state.target_card.type == 'hand' then
        skip = drag_state.target_card.x + 1
    end

    local dims = card_dimensions()

    for n=1, 4 do
        local cx, cy, cw, ch = hand_coords(n)
        love.graphics.push()
        love.graphics.translate(cx, cy)

        if n == skip then draw_card(nil)
        else draw_card(hand[n]) end
        love.graphics.pop()
    end

    love.graphics.pop()
end

function draw_board(board)
    local dims = card_dimensions()
    for y = 0, 8 do
        for x = 0, 11 do
            local cx, cy, cw, ch = card_coords(x, y)
            love.graphics.push()
            love.graphics.translate(cx, cy)
            draw_card(board[y][x])
            love.graphics.pop()
        end
    end
end

function draw_card(card)
    local dims = card_dimensions()

    if card == nil then
        love.graphics.setColor(200, 200, 0)
        love.graphics.rectangle('line', 0, 0, dims.width, dims.height, 3, 3)
    else
        local suit = card:sub(1,1)
        local rank = card:sub(2,3)

        local quad = nil
        if suit == 'b' then
            quad = card_quad(13, 0)
        else
            local suits = { s=0, c=1, d=2, h=3 }
            local ranks = { a=0,
                            ['2']=1, ['3']=2, ['4']=3, ['5']=4, ['6']=5,
                            ['7']=6, ['8']=7, ['9']=8, ['10']=9,
                            j=10, q=11, k=12 }

            quad = card_quad(ranks[rank], suits[suit])
        end

        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(CardsPng, quad, 0, 0, 0, dims.scale, dims.scale)
    end
end

function card_quad(x, y)
    local w,h = 140, 190
    return love.graphics.newQuad(x*w, y*h, w, h, CardsPng:getWidth(), CardsPng:getHeight())
end

function hand_coords(n)
    local dims = card_dimensions()
    local x,y = card_coords(n-1, 4)
    x = x + dims.status_left - dims.left
    return x, y, dims.width, dims.height
end

function card_coords(x, y)
    local dims = card_dimensions()

    return dims.left + x*(dims.width+dims.spacing),
           dims.top + y*(dims.height+dims.spacing),
           dims.width, dims.height
end

function pixel_to_card(x, y)
    local dims = card_dimensions()

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

function card_dimensions()
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

    return {
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
end

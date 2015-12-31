function draw_game(game)
    draw_board(game.board)
    draw_hand(game.hand)
end

function draw_hand(hand)
    love.graphics.push()

    local dims = card_dimensions()
    love.graphics.translate(dims.status_left, 0)

    for n=1, 4 do
        local cx, cy, cw, ch = card_coords(n-1, 4)
        love.graphics.push()
        love.graphics.translate((n-1)*(cw+dims.spacing), cy)
        draw_card(hand[n])
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

function card_coords(x, y)
    local dims = card_dimensions()

    return dims.left + x*(dims.width+dims.spacing),
           dims.top + y*(dims.height+dims.spacing),
           dims.width, dims.height
end

function pixel_to_card(x, y)
    local dims = card_dimensions()

    x = x - dims.left + dims.spacing/2
    y = y - dims.top + dims.spacing/2

    return math.floor(x / (dims.width+dims.spacing)), math.floor(y / (dims.height+dims.spacing))
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
    local left = math.floor((orig_w - 16*scaled_card_width - 14*spacing - h_divide)/2)
    local status_left = left + 12*scaled_card_width + 11*spacing + h_divide

    return {
        width = scaled_card_width,
        height = scaled_card_height,
        scale = scale,
        top = top,
        left = left,
        status_left = status_left,
        spacing = spacing }
end

drag_state = {
    dragging = false,
    mousedown = false,
    startx = nil,
    starty = nil,
    target_card = nil
}

function love.mousemoved(x,y,dx,dy)
    -- We only care if we're actually doing something that could be a drag
    if not drag_state.mousedown then return end

    -- This is the start of a drag:
    if drag_state.mousedown and not drag_state.dragging then
        drag_state.dragging = true
        drag_state.startx = x
        drag_state.starty = y
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        drag_state.mousedown = true

        local type, cx, cy = pixel_to_card(x,y)
        if type then -- Actual card!
            drag_state.target_card = {type=type, x=cx, y=cy}
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        drag_state.mousedown = false

        -- This ends a drag:
        if drag_state.dragging then
            drag_state.dragging = false
            drag_state.target_card = nil
        end
    end
end

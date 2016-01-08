UI = class('UI')

function UI:initialize(game)
    self.drag_state = {
        dragging = false,
        mousedown = false,
        startx = nil,
        starty = nil,
        target_card = nil
    }

    self.game = game
    self.drawing = drawing
end

function UI:dragged_value()
    if not self.drag_state.target_card then
        return nil
    elseif self.drag_state.target_card.type == 'hand' then
        return self.game.hand[self.drag_state.target_card.x+1]
    else
        return self.game.board[self.drag_state.target_card.y][self.drag_state.target_card.x]
    end
end

function UI:install(system)
    system = system or love

    system.mousemoved = function(...) self:mousemoved(...) end
    system.mousepressed = function(...) self:mousepressed(...) end
    system.mousereleased = function(...) self:mousereleased(...) end
end

function UI:mousemoved(x,y,dx,dy)
    -- We only care if we're actually doing something that could be a drag
    if not self.drag_state.mousedown then return end

    -- This is the start of a drag:
    if self.drag_state.mousedown and not self.drag_state.dragging and self.drag_state.target_card then
        self.drag_state.dragging = true
        self.drag_state.startx = x
        self.drag_state.starty = y
    end
end

function UI:mousepressed(x, y, button, istouch)
    if button == 1 then
        self.drag_state.mousedown = true

        local type, cx, cy = self.drawing:pixel_to_card(x,y)
        if self.game:movable(type, cx, cy) then -- Actual card!
            self.drag_state.target_card = {type=type, x=cx, y=cy}
        end
    end
end

function UI:mousereleased(x, y, button)
    if button == 1 then
        self.drag_state.mousedown = false

        -- This ends a drag:
        if self.drag_state.dragging then
            local drop = self.drawing:closest_drop()

            if drop then
                local card = self.drag_state.target_card
                self.game:place_card(card, self:dragged_value(), drop.x, drop.y)
            end

            self.drag_state.dragging = false
            self.drag_state.target_card = nil
        end
    end
end

function UI:dragging() return self.drag_state.dragging end
function UI:start() return self.drag_state.startx, self.drag_state.starty end
function UI:card_type()
    if self.drag_state.target_card then
        return self.drag_state.target_card.type
    else
        return nil
    end
end
function UI:card_coords()
    if self.drag_state.target_card then
        return self.drag_state.target_card.x, self.drag_state.target_card.y
    else
        return nil
    end
end

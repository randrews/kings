function intersect(x1, y1, w1, h1,
                   x2, y2, w2, h2) -- Return whether two rectangles intersect

    local function inside(x,y)
        return x >= x2 and x <= x2+w2 and y >= y2 and y <= y2+h2
    end

    return inside(x1, y1) or inside(x1+w1, y1) or inside(x1,y1+h1) or inside(x1+w1, y1+h1)
end

function distance(x1,y1,x2,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

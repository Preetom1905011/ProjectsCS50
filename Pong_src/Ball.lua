Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    --generate ballspeed (X axis)
    self.dx = math.random(2) == 1 and -200 or 200 -- ternary operator (cond? true: false) in Lua, ensures can go left and right 
    --generate ballspeed (Y axis)
    self.dy = math.random(-100, 100) -- ensures can go up and down
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = math.random(2) == 1 and -200 or 200 
    self.dy = math.random(-100, 100)
end

function Ball:collides(box)
    if self.x > box.x + box.width or self.x + self.width < box.x then
        return false
    end

    if self.y > box.y + box.height or  self.y + self.height < box.y then
        return false
    end

    return true
end

function Ball:render()
    --draw pong ball
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height) -- 2 is minused to put the center roughly in the middle
end
Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dy = 0
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt) -- math.max returns the greater of two nums so that Y can't be negative
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - 20, self.y + self.dy * dt) -- max.min returns the smaller of two nums so that Y position does not exceed the screen height
    end
end

function Paddle:render()
    --draw paddle
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
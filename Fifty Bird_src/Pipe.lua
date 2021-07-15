Pipe = Class{}

local PIPE_IMAGE = love.graphics.newImage('graphics/pipe.png')

function Pipe:init(orientation, y)
    self.x = VIRTUAL_WIDTH + 32
    self.y = y

    self.width = PIPE_IMAGE:getWidth()
    self.height = PIPE_HEIGHT

    self.orientation = orientation
end

function Pipe:update(dt)
    --self.x = self.x + PIPE_SPEED * dt
end

function Pipe:render()
    love.graphics.draw(PIPE_IMAGE, self.x,
        (self.orientation == 'top' and self.y + self.height or self.y),
        0, 1, self.orientation == 'top' and -1 or 1)
end
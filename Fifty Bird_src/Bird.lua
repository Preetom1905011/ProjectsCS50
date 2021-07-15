Bird = Class{}

GRAVITY = 20
JUMP_VELOCITY = -4

function Bird:init()
    self.image = love.graphics.newImage('graphics/bird.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.x = VIRTUAL_WIDTH / 2 - (self.width / 2)
    self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)

    self.dy = 0
end

function Bird:collides(pipe)
    --give a little offset to make more player friendly
    if (self.x + 2) + (self.width - 4) >= pipe.x and (self.x + 2) <= pipe.x + PIPE_WIDTH then
        if (self.y + 2) + (self.height - 4) >= pipe.y and (self.y + 2) <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end

    return false
end

function Bird:update(dt)
    self.dy = self.dy + GRAVITY * dt

    if love.keyboard.wasPressed('space') or love.mouse.wasPressed(1) then
        sounds['jump']:play()
        self.dy = JUMP_VELOCITY
    end
    
    self.y = self.y + self.dy
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end
Bolt = Class{}

BOLT_SPEED = 300

function Bolt:init(x, y)
    self.width = 128
    self.height = 128

    bolt = love.graphics.newImage('graphics/bolt.png')
    arrow = love.graphics.newImage('graphics/arrow.png')

    if playerChoice == 'A' then
        self.texture = bolt
    elseif playerChoice == 'B' then
        self.texture = arrow
    end

    self.x = x + self.width / 2
    self.y = y

    self.dx = 200 + (level - 1) * 100

end

function Bolt:update(dt)
    self.x = self.x + self.dx * dt

end

function Bolt:hit(enemy)
    if enemy.state ~= 'dying' then
        if enemy.x < self.x + self.width / 2 and enemy.y == self.y and enemy.x > 64 then
            return true
        end
    end    
    return false
end

function Bolt:render()
    if playerChoice == 'A' then
        love.graphics.setColor(0/255,20/255,209/255,1)--deep blue
    end
    love.graphics.draw(self.texture, self.x, self.y)
    love.graphics.setColor(1,1,1,1) --set default color

end
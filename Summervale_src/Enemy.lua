Enemy = Class{}

require 'Util'
require 'Animation'

function Enemy:init()
    self.x = math.random(VIRTUAL_WIDTH + 2 * 128, VIRTUAL_WIDTH + 7 * 128)
    startBlock = math.random(6)
    self.y = 128 * (startBlock - 1)

    self.frames = {}
    --self.map = map

    self.width = 128
    self.height = 128

    if level == 1 then
        self.frames = generateGolem1()
        self.health = 10
        tagline = "The Forest Trolls"
    elseif level == 2 then
        self.frames = generateGolem2()
        self.health = 20
        tagline = "The Mountain Golems"
    elseif level == 3 then
        self.frames = generateGolem3()
        self.health = 30
        tagline = "The White Walkers"
    else
        self.frames = generateBlank()
    end

    self.die_count = 0

    self.state = 'walking'

    self.walk_speed = 0

    self.animations = {
        ['idle'] = Animation{
            frames = {
                self.frames[1]
            },
            interval = 1
        },
        ['walking'] = Animation{
            frames = {
                self.frames[1], self.frames[2], self.frames[3], self.frames[4],
                self.frames[5], self.frames[6], self.frames[7], self.frames[8],
                self.frames[9], self.frames[10], self.frames[11], self.frames[12],
                self.frames[13], self.frames[14], self.frames[15], self.frames[16],
                self.frames[17]
            },
            interval = 0.15
        },
        ['dying'] = Animation{
            frames = {
                self.frames[1], self.frames[18], self.frames[19], self.frames[20],
                self.frames[21], self.frames[22], self.frames[23], self.frames[24],
                self.frames[25], self.frames[26]
            },
            interval = 0.1
        }
    }

    self.animation = self.animations['walking']
    self.currentFrame = self.animation:getCurrentFrame()

    self.behaviors = {
        ['idle'] = function(dt)
            self.walk_speed = 0
            self.state = 'idle'
            self.animation = self.animations['idle']
        end,
        ['walking'] = function(dt)
            if Difficulty == 'easy' then
                self.walk_speed = -64 - (level - 1) * 3
            else
                self.walk_speed = -67 - (level - 1) * 3
            end

        end,
        ['dying'] = function(dt)
            self.die_count = self.die_count + 1
            self.walk_speed = 0
            self.state = 'dying'
            self.animation = self.animations['dying']
            if self.die_count >= 0.1 * 9 * FPS then
                self.x = 0 - 5 * 128
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
        end
    }

end

function Enemy:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()

    self.x = self.x + self.walk_speed * dt

end

function Enemy:render()
    love.graphics.draw(self.currentFrame, self.x + self.width / 2, self.y + self.height / 2, 0, -1, 1, self.width / 2, self.height / 2)
end
Player = Class{}

require 'Util'
require 'Bolt'
require 'Animation'

MOVE_DIST = 0
cooldown = 0

die_count = 0

function Player:init(map)
    self.width = 128
    self.height = 128

    self.x = 0
    self.y = map.tileHeight * 2

    self.dx = 0
    self.dy = 0

    MOVE_DIST = self.height

    lives = 5

    self.map = map

    self.bolts = {}

    heroA = {}

    heroA[1] = love.graphics.newImage('graphics/elf/elf1.png')
    heroA[2] = love.graphics.newImage('graphics/elf/elf2.png')

    heroB = {}

    heroB[1] = love.graphics.newImage('graphics/elf/hero2_1.png')
    heroB[2] = love.graphics.newImage('graphics/elf/hero2_2.png')

    self.frames = {}

    if playerChoice == 'A' then
        self.frames = heroA
    elseif playerChoice == 'B' then
        self.frames = heroB
    end
    if level == 1 then
        coolCounter = FPS / 8
    elseif level == 2 then
        coolCounter = FPS / 12
    elseif level == 3 then
        coolCounter = FPS / 15
    end
    self.state = 'idle'

    self.animations = {
        ['idle'] = Animation{
            frames = {
                self.frames[1]
            },
            interval = 1
        },
        ['attack'] = Animation{
            frames = {
                self.frames[2]
            },
            interval = 0.1
        }
    }

    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    self.behaviors = {
        ['idle'] = function(dt)
            cooldown = cooldown + 1
            if love.keyboard.wasPressed('space') and cooldown > coolCounter then
                sounds['shoot']:setVolume(1)
                sounds['shoot']:play()
                self.bolts[#self.bolts + 1] = Bolt(self.x , self.y)
                cooldown = 0
                self.dy = 0
                self.state = 'attack'
                self.animation = self.animations['attack']

            elseif love.keyboard.wasPressed('up') then
                self.dy = -MOVE_DIST
            elseif love.keyboard.wasPressed('down') then
                self.dy = MOVE_DIST
            else
                self.dy = 0
            end
        end,
        ['attack'] = function(dt)
            cooldown = cooldown + 1
            if love.keyboard.isDown('space') then
                self.dy = 0
                self.state = 'attack'
                self.animation = self.animations['attack']
            elseif love.keyboard.wasPressed('up') then
                self.dy = -MOVE_DIST
            elseif love.keyboard.wasPressed('down') then
                self.dy = MOVE_DIST
            else
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
        end


    }

end

function Player:update(dt)
    for i, bolt in ipairs(self.bolts) do
        self.bolts[i]:update(dt)
    end

    for i = #self.bolts, 1, -1 do
        if self.bolts[i].x > VIRTUAL_WIDTH or self.bolts[i].x < 0 - 2 * self.map.tileWidth then
            table.remove(self.bolts, i)
        elseif #enemies ~= 0 then
            for j = #enemies, 1, -1 do
                if self.bolts[i]:hit(enemies[j]) then
                    enemies[j].die_count = 0
                    enemies[j].health = enemies[j].health - 10
                    
                    self.bolts[i].dx = 0
                    self.bolts[i].x = 0 - 5 * self.map.tileWidth

                    if enemies[j].health == 0 then
                        sounds['golem_dead']:setVolume(1)
                        sounds['golem_dead']:play()
                        enemies[j].state = 'dying'
                    else
                        sounds['golem_hit']:setVolume(1)
                        sounds['golem_hit']:play()
                    end
                end
            end
        end
    end

    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy)
    elseif self.dy > 0 then
        self.y = math.min(self.y + self.dy, VIRTUAL_HEIGHT - self.height)
    end
end

function Player:render() 
    love.graphics.draw(self.animation:getCurrentFrame(), self.x, self.y)
    for i, bolt in ipairs(self.bolts) do
        self.bolts[i]:render()
    end
    
end
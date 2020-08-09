Map = Class{}

require 'Player'
require 'Enemy'

TILE_GRASS_1 = 1
TILE_GRASS_2 = 2

level = 1
waves = 3

countdown = 0

function Map:init()

    self.tileWidth = 128
    self.tileHeight = 128

    self.mapWidth = 30
    self.mapHeight = 28

    wave_count = 1
    
    quads = {}

    enemies = {}

    self:generateEnimies()

    quads[TILE_GRASS_1] = love.graphics.newImage('graphics/grass_1.png')
    quads[TILE_GRASS_2] = love.graphics.newImage('graphics/grass_2.png')

    self.tileSprites = quads
    self.player = Player(self)
    --a storage for maps
    self.tiles = {}

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            if y % 2 == 0 then
                self:setTile(x, y, TILE_GRASS_1)
            else
                self:setTile(x, y, TILE_GRASS_2)
            end
        end
    end

end

function Map:generateEnimies()
    if Difficulty == 'easy' then
        golem_count = 45
    elseif Difficulty == 'hard' then
        golem_count = 55
    end
    for i = 1, golem_count - (level - 1) * 5 do
        enemies[i] = Enemy(self)
    end
end

function Map:reset()
    wave_count = 0
    level = 1
    lives = 5
    self.player.x = 0
    self.player.y = map.tileHeight * 2

    for i = #enemies, 1, -1 do
        table.remove(enemies, i)
    end

    for i = #self.player.bolts, 1, -1 do
        table.remove(self.player.bolts, i)
    end
end



function Map:update(dt)
    
    countdown = countdown + 1
    if gameState == 'play' then
        self.player:update(dt)

        for i, enemy in ipairs (enemies) do
            enemies[i]:update(dt)
        end
    end

    for i = #enemies, 1, -1 do
        if enemies[i].x < 0 - self.tileWidth then
            if enemies[i].x >  0 - 3 * self.tileWidth then
                sounds['golem_passed']:setVolume(1)
                sounds['golem_passed']:play()
                lives = lives - 1
            end
            table.remove(enemies, i)
            if lives == 0 then
                gameState = 'lose'
                musics['level'..tostring(level)]:stop()
            end
        end
    end

    if level == 3 and wave_count == waves and #enemies == 0 then
        if lives > 0 then
            gameState = 'win'
            musics['level'..tostring(level)]:stop()
        else
            gameState = 'lose'
            musics['level'..tostring(level)]:stop()
        end
    end

    if #enemies == 0 and wave_count == waves and level < 3 then
        musics['level'..tostring(level)]:stop()
        countdown = 0
        level = level + 1
        self.generateEnimies()
        wave_count = 1
        gameState = 'level_start'
    end
    
    if #enemies == 0 and wave_count <= waves - 1 then
        wave_count = wave_count + 1
        self:generateEnimies()
        countdown = 0
        if lives ~= 0 then
            gameState = 'wave_start'
        end
    end
    
    if gameState == 'wave_start' and countdown == 90  then
        gameState = 'play'
    end
end

--returns co-ordinates in pixel
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            love.graphics.draw(self.tileSprites[tile], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end

    if gameState == 'play' or gameState == 'quit_box' then
        for i, enemy in ipairs(enemies) do 
            enemies[i]:render()
        end
    end
    
    self.player:render()

    love.graphics.setFont(smallFont)
    love.graphics.setColor(.9, 0, 0, 1)
    
    love.graphics.printf("Lives: "..tostring(lives), 0, 0, VIRTUAL_WIDTH, 'left')

    love.graphics.setColor(44/255, 26/255, 116/255, 1) -- dark purple
    love.graphics.printf("level: "..tostring(level), 0, 0, VIRTUAL_WIDTH, 'right')
    love.graphics.printf(tostring(Difficulty).." Mode", 0, 32, VIRTUAL_WIDTH, 'right')
    love.graphics.setColor(1,1,1,1) -- set default
end
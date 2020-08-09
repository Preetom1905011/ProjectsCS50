--link to other classes
require 'Util'
require 'Player'

Map = Class{}

--these corresponding numbers can be calculated by the chopping off of quads and which num corresponds to which tile
TILE_BRICK = 1
TILE_EMPTY = 4

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

POLE_TOP = 8
POLE_MIDDLE = 12
POLE_BOTTOM = 16
FLAG = 13

--declare scrolling speed of camera
local SCROLL_SPEED = 62

function Map:init()
    --store the spritesheet in memory for chopping
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')

    --link the music, this one is from( https://freesound.org/people/Magntron/sounds/335571/ )
    --self.music = love.audio.newSource('sounds/music.mp3', 'static')
    self.tileWidth = 16
    self.tileHeight = 16
    --set the map(that will essentially be a storage of unique numbers/index that will draw the picture) dimensions in num
    self.mapWidth = 300
    self.mapHeight = 28
    --create a storage for map
    self.tiles = {}

    --co-ordinates for the camera, so to speak
    self.camX = 0
    self.camY = -3

    --declare gravity
    self.gravity = 15
    --call the player object
    self.player = Player(self) -- the Player class takes an argument of the map itself

    --use function from Util.lua to chop up the spritesheet into quads/sprites
    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    --get the map dimensions in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    
    --choose randomly if day or night
    if math.random(2) == 1 then
        day = true
    else 
        night = true
    end

    --first, fill out the entire map with empty spaces
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            -- store tile info in an array
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    --begin generating the terrain (randomly) using vertical scan lines
    local x = 1
    --ensure ground where our player first starts
    for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(11, y, TILE_BRICK)
    end
    --put the end flag
    self:setTile(self.mapWidth - 3, self.mapHeight / 2 - 3, POLE_TOP)
    self:setTile(self.mapWidth - 3, self.mapHeight / 2 - 2, POLE_MIDDLE)
    self:setTile(self.mapWidth - 3, self.mapHeight / 2- 1, POLE_BOTTOM)
    self:setTile(self.mapWidth - 2, self.mapHeight / 2- 3, FLAG)
    --draw ground beneath pole
    for y = self.mapHeight / 2, self.mapHeight do 
        self:setTile(self.mapWidth - 3, y, TILE_BRICK)
    end

    --loop over column by column instead of row by row
    while x <= self.mapWidth do

        --10% chance to create a cloud
        --making sure that atleast 2 tiles from the right edge(since going left to right)
        if x < self.mapWidth - 2 then
            if math.random(10) == 1 then
                --choose a random vertical spot where blocks generate (some space above the ground)
                local cloudStart = math.random(self.mapHeight / 2 - 8)

                --draw left and right cloud
                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        --10% chance of a bush, ensuring that away from edge
        if math.random(10) == 1 and x < self.mapWidth - 4 then
            --bush above ground
            local bushStart = self.mapHeight / 2 - 1
            -- draw bush(left) , then bricks underneath
            self:setTile(x, bushStart, BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            --GO TO NEXT COLUMN
            x = x + 1

            --draw bush(right), then bricks underneath
            self:setTile(x, bushStart, BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            --GO TO NEXT COLUMN
            x = x + 1
        end

        --5% chance to generate a mushroom
        if math.random(20) == 1 and x ~= self.mapWidth - 3 then
            --draw the ground
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            --place the mushroom on top of the ground
            self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
            self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)

            --GO TO NEXT COLUMN
            x = x + 1

        --10% chance to not generate anything, creating a gap
        elseif math.random(10) ~= 1 then
            --create bricks
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            -- 1/15 chance to create a block for mario to hit
            if math.random(15) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end

            --GO TO NEXT COLUMN
            x = x + 1

        -- 20% chance of a stair
        elseif math.random(5) == 1 and x < self.mapWidth - 10 and x > 2 then
            local steps = math.random(2, 6)
            for n = 1, steps do
                for y = self.mapHeight / 2 - n, self.mapHeight do
                    self:setTile(x, y, TILE_BRICK) 
                end
                --1/20 chance of a coin block on top of a stair
                if math.random(20) == 1 then
                    self:setTile(x, self.mapHeight / 2 - n - 6, JUMP_BLOCK)
                end
                x = x + 1
            end

        --otherwise skip 2 columns, creating a 2 line gap
        else
            x = x + 2
        end
    end
end

-- return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end
--return whether the blocks are winning blocks(flag, pole)
function Map:wins(tile)
    --define win blocks
    local win_collidables = {
        POLE_TOP, POLE_MIDDLE, POLE_BOTTOM, FLAG
    }
    --iterate and return if tile matches
    for _,v in ipairs(win_collidables) do
        if tile.id == v then
            return true
        end
    end
    return false
end

function Map:update(dt)

    --give the player the dt parameter
    self.player:update(dt)

   --update camera offset with respect to dt
   --basically the camera will follow the player(keeping him at the center) until the very edge
   self.camX = math.max(0,
                math.min(self.player.x - VIRTUAL_WIDTH / 2, 
                    math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))
end

--gets tile type from the map based on pixel co-ordinates
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

--a function that gives index of a 1D array (but acts as a 2D) to store quad info in map
function Map:setTile(x, y, id)
    --[[ this is a 1D array, but the numbers can be stored as 2D
        map = {
            0, 0, 0, 0, 0       here y = 1, so the indices will be 1 - 5 
            0, 0, 0, 0, 0,      here y = 2, so the indices will be x + map.width , so x + 5, so indices will be 6- 10
            1, 1, 1, 1, 1       in this way, a 1D array can be used to store 2D info
        }
    ]]
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

--funtion that returns sprites or quads info based on map
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end 
--reset function after every level
function Map:reset()
    --self.music:stop()
    self:init()
    self.player:reset()
end

function Map:render()
    --draw the map
    --the tables in lua are 1 indexed, but pixels are 0 indexed
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                --function(the big image, chopped up quads(the indices), the co-ordinates where it should be drawn)
                love.graphics.draw(self.spritesheet, self.tileSprites[tile], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    --render the player
    self.player:render()
    
    love.graphics.setFont(textfont)
    love.graphics.setColor(254 / 255, 218 / 255, 16 / 255, 1) -- yellow
    love.graphics.print("Coins: " ..tostring(coin_count), self.camX + 2, self.camY + 2)

end
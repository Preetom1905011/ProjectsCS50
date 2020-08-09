Player = Class{}

--link the animation class
require 'Animation'

--declare movement speed of avatar
MOVE_SPEED = 140
--declare jump velocity and gravity
JUMP_VELOCITY = 400
--to count coins
coin_count = 0

function Player:init(map)
    self.width = 16
    self.height = 20

    --where the player will be standing
    self.x = map.tileWidth * 10
    self.y = 0

    --player velocity
    self.dx = 0
    self.dy = 0

    --reference map for checking tiles
    self.map = map
    --chop up the avatar from spritesheet
    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, self.width, self.height)

    --sound effects
    self.sound = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['die'] = love.audio.newSource('sounds/die.wav', 'static')
    }
    --set default state
    self.state = 'idle'
    --set default direction
    self.direction = 'right'

    --declare the animation states(a table)
    --if the argument of a function is only one table, can use function{...} instead of function({...})
    self.animations = {
        ['idle'] = Animation{
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            interval = 1 --doesn't really matter for idle state
        },
        ['walking'] = Animation{
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[10], self.frames[11]
            },
            interval = 0.15
        },
        ['jumping'] = Animation{
            texture = self.texture,
            frames = {
                self.frames[3]
            },
            interval = 1
        }
    }

    --default declaration
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    --create a state engine instead of a lot of if statements
    self.behaviors = {
        --these are called states
        ['idle'] = function(dt)
            --won't move unless play state
            if gameState == 'play' then
                --player jump controls
                --create a custom function for when a key is only pressed once
                if love.keyboard.wasPressed('space') then
                    self.dy = -JUMP_VELOCITY
                    self.state = 'jumping'
                    self.animation = self.animations['jumping']
                    self.sound['jump']:play()
                    
                --player movement controls
                elseif love.keyboard.isDown('right') then
                    self.dx = MOVE_SPEED
                    --change state to walking and assign correct direction
                    self.state = 'walking'
                    self.animation = self.animations['walking']
                    self.direction = 'right'

                elseif love.keyboard.isDown('left') then
                    self.dx = -MOVE_SPEED
                    --change state to walking assign correct direction
                    self.state = 'walking'
                    self.animation = self.animations['walking']
                    self.direction = 'left'

                else
                    --stop changing frames/ change state to idle
                    self.dx = 0
                end
            --if not in play mode stop
            else
                self.dx = 0
            end


            --check if there's a block beneath the player(left and right side)
            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                --if so, reset velocity and state to jumping
                --because if don't encounter a block beneath means falling!!
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
        end,
        ['walking'] = function(dt)
            --won't move unless playing
            if gameState == 'play' then
                --player jump controls
                --create a custom function for when a key is only pressed once
                if love.keyboard.wasPressed('space') then
                    self.dy = -JUMP_VELOCITY
                    self.state = 'jumping'
                    self.animation = self.animations['jumping']
                    self.sound['jump']:play()

                --player movement controls
                elseif love.keyboard.isDown('right') then
                    self.dx = MOVE_SPEED
                    --change state to walking assign correct direction
                    self.animation = self.animations['walking']
                    self.direction = 'right'

                elseif love.keyboard.isDown('left') then
                    self.dx = -MOVE_SPEED
                    --change state to walking assign correct direction
                    self.animation = self.animations['walking']
                    self.direction = 'left'

                else
                    --stop changing frames/ change state to idle
                    self.dx = 0
                    self.state = 'idle'
                    self.animation = self.animations['idle']
                end
            --if not in play mode stop
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            --check for collisions moving left and right
            self:checkLeftCollision()
            self:checkRightCollision()

            --check if there's a block beneath the player(left and right side)
            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                --if so, reset velocity and state to jumping
                --because if don't encounter a block beneath means falling!!
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
        end,
        ['jumping'] = function(dt)
            --when falls into a pit
            if self.y > 300 then
                if self.y < 400 then
                    gameState = 'gameover'
                    self.sound['die']:play()
                end
                return
            end
            --won't move unless play state
            if gameState == 'play' then
                --movement controls when in air, no state change
                if love.keyboard.isDown('left') then
                    self.dx = -MOVE_SPEED
                    self.direction = 'left'

                elseif love.keyboard.isDown('right') then
                    self.dx = MOVE_SPEED
                    self.direction = 'right'
                end
            --if not in play mode stop
            else
                self.dx = 0
            end
            --apply gravity
            self.dy = self.dy + self.map.gravity

            -- check if there's a tile directly beneath us
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                -- if so, reset velocity and position and change state
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
        end
    }

end

function Player:update(dt)
    --update the state functions for animation
    self.behaviors[self.state](dt)
    --update the frame transition in animation
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    --movement actions (x axis)
    if self.direction == 'left' then
        self.x = math.max(0, math.floor(self.x + dt * self.dx))
    elseif self.direction == 'right' then
        self.x = math.min(math.floor(self.x + dt * self.dx), self.map.mapWidth * self.map.tileWidth - self.width)
    end
    --call jump/hit function
    self:calculateJumps()

    --movement actions (y axis)
    self.y = math.floor(self.y + dt * self.dy)

end
--for calculating hit while jumping
function Player:calculateJumps()
    --variables to keep a tab on which block has been hit(J_B or J_B_H)
    local playCoin = false
    local playHit = false
    --check if the player's head hits a block while jumping up
    if self.dy < 0 then 
        if self.map:tileAt(self.x, self.y).id ~= TILE_EMPTY or self.map:tileAt(self.x + self.width - 1, self.y).id ~= TILE_EMPTY then
            --reset y velocity, fall basically
            self.dy = 0

            --if hit a block, change it
            if self.map:tileAt(self.x, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1, math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                
                playCoin = true
                coin_count = coin_count + 1
            else
                playHit = true
            end

            if self.map:tileAt(self.x + self.width - 1, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth) + 1, math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                
                playCoin = true
                coin_count = coin_count + 1
            else
                playHit = true
            end

            if playCoin then
                self.sound['coin']:play()
            elseif playHit then
                self.sound['hit']:play()
            end
        end
    end
end

-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile left of us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        end
        --check if hit a win block
        if self.map:wins(self.map:tileAt(self.x - 1, self.y)) or
            self.map:wins(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
                gameState = 'win'
                --time remaining after level ends
                time_saved = time_left
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile right of us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
        --check if hit a win block
        if self.map:wins(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:wins(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
                gameState = 'win'
                --time remaining after level ends
                time_saved = time_left
        end
    end
end
--to reset after every level
function Player:reset()
    --where the player will be standing
    self.x = map.tileWidth * 10
    self.y = 0

    --player velocity
    self.dx = 0
    self.dy = 0

    --set default state
    self.state = 'idle'
    --set default direction
    self.direction = 'right'
end

function Player:render()
    --the draw function has additional 5 arguments:
    --rotation, scaleX(stretch or compress w.r.t x axis), scaleY, co-ordinates for the center of scaling
    --negative scaling means flip it
    local scaleX
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end
    --draw the avatar , consider the scale point shift in stating the position
    love.graphics.draw(self.texture, self.animation:getCurrentFrame(), self.x + self.width / 2, self.y + self.height / 2,
        0, scaleX, 1, self.width / 2, self.height/ 2)

end
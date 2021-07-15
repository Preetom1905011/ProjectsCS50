PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.Timer = 0

    self.lastY = -PIPE_HEIGHT + 20 + math.random(40, 80)

    --score counter
    self.score = 0
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('p') then
        sounds['click']:play()
        if gPaused then
            gPaused = false
        else
            gPaused = true
        end
    end

    if not gPaused then
        self.Timer = self.Timer + dt
        pipe_timer = math.random(2, 40)
        if self.Timer > pipe_timer then
            local y = math.max(-PIPE_HEIGHT + 10,
                    math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - GAP_HEIGHT - PIPE_HEIGHT))
            self.lastY = y

            table.insert(self.pipePairs, PipePairs(y))
            self.Timer = 0
        end

        for k, pair in pairs(self.pipePairs) do
            --check if bird passes the pipes
            --increment the score if it has
            if not pair.scored then
                if self.bird.x > pair.x + PIPE_WIDTH then
                    sounds['point']:play()
                    self.score = self.score + 1
                    pair.scored = true
                end
            end

            pair:update(dt)
        end

        for k, pair in pairs(self.pipePairs) do
            if pair.x < -PIPE_WIDTH then
                table.remove(self.pipePairs, k)
            end
        end

        
        for k, pair in pairs(self.pipePairs) do
            --check if bird collides with either of the pipes
            for l, pipe in pairs(pair.pipes) do
                if self.bird:collides(pipe) then
                    sounds['explosion']:play()
                    sounds['die']:play()
                    gStateMachine:change('score', {
                        score = self.score
                    })
                end
            end
        end
        
        self.bird:update(dt)
        --dead if touches ground
        if self.bird.y > VIRTUAL_HEIGHT - 15 then
            sounds['explosion']:play()
            sounds['die']:play()
            gStateMachine:change('score', {
                score = self.score
            })
        end
    end
end

function PlayState:render()
    for k, pipe in pairs(self.pipePairs) do
        pipe:render()
    end
    love.graphics.setFont(mediumFont)
    love.graphics.print("SCORE: "..tostring(self.score), 8, 8)
    
    self.bird:render()

    if gPaused then
        love.graphics.setFont(flappyFont)
        love.graphics.setColor(228/255, 17/255, 91/255, 1)--magenta
        love.graphics.printf("PAUSED", 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)--white
    end

end
ScoreState = Class{__includes = BaseState}

gold_medal = love.graphics.newImage('graphics/gold.png')
silver_medal = love.graphics.newImage('graphics/silver.png')
bronze_medal = love.graphics.newImage('graphics/bronze.png')

function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        sounds['click']:play()
        gStateMachine:change('instruction')
    end
end

function ScoreState:render()
    love.graphics.setFont(flappyFont)
    if self.score < 10 then
        love.graphics.setColor(228/255, 17/255, 91/255, 1)--magenta
        love.graphics.printf("OOPS! YOU'RE DEAD", 0, 48, VIRTUAL_WIDTH, 'center')
    elseif self.score < 20 then
        love.graphics.draw(bronze_medal, VIRTUAL_WIDTH / 2 - 24, VIRTUAL_HEIGHT / 2 - 32)
        love.graphics.setColor(197/255, 83/255, 13/255, 1)--bronze
        love.graphics.printf("YOU GET THE BRONZE MEDAL!", 0, 48, VIRTUAL_WIDTH, 'center')
    elseif self.score < 30 then
        love.graphics.draw(silver_medal, VIRTUAL_WIDTH / 2 - 24, VIRTUAL_HEIGHT / 2 - 32)
        love.graphics.setColor(155/255, 144/255, 120/255, 1)--silver
        love.graphics.printf("YOU GET THE SILVER MEDAL!", 0, 48, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.draw(gold_medal, VIRTUAL_WIDTH / 2 - 24, VIRTUAL_HEIGHT / 2 - 32)
        love.graphics.setColor(236/255, 174/255, 39/255, 1)--gold
        love.graphics.printf("YOU GET THE GOLD MEDAL!", 0, 48, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(1, 1, 1, 1)--white
    love.graphics.printf("SCORE: "..tostring(self.score), 0, 90, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(mediumFont)
    love.graphics.setColor(228/255, 165/255, 17/255, 1)--yellowish/chrome
    love.graphics.printf("PRESS ENTER TO PLAY AGAIN", 0, 220, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)--white
end